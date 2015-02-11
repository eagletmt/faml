require 'temple'
require 'fast_haml/ast'
require 'fast_haml/attribute_normalizer'
require 'fast_haml/filter_compilers'
require 'fast_haml/static_hash_parser'
require 'fast_haml/text_compiler'

module FastHaml
  class Compiler < Temple::Parser
    def initialize(*)
      super
      @text_compiler = TextCompiler.new
    end

    def call(ast)
      compile(ast)
    end

    private

    def compile(ast)
      case ast
      when Ast::Root
        compile_root(ast)
      when Ast::Doctype
        compile_doctype(ast)
      when Ast::HtmlComment
        compile_html_comment(ast)
      when Ast::HamlComment
        [:multi]
      when Ast::Element
        compile_element(ast)
      when Ast::Script
        compile_script(ast)
      when Ast::SilentScript
        compile_silent_script(ast)
      when Ast::Text
        compile_text(ast)
      when Ast::Filter
        compile_filter(ast)
      else
        raise "InternalError: Unknown AST node #{ast.class}: #{ast.inspect}"
      end
    end

    def compile_root(ast)
      [:multi, [:newline]].tap do |temple|
        compile_children(ast, temple)
      end
    end

    def compile_children(ast, temple)
      was_newline = false
      ast.children.each do |c|
        if c.is_a?(Ast::Element) && c.nuke_outer_whitespace && was_newline
          # pop newline
          x = temple.pop
          if x != [:newline]
            raise "InternalError: Unexpected pop (expected [:newline]): #{x}"
          end
          x = temple.pop
          if x != [:static, "\n"]
            raise "InternalError: Unexpected pop (expected [:static, newline]): #{x}"
          end
        end
        temple << compile(c)
        if was_newline = need_newline?(ast, c)
          temple << [:static, "\n"]
          temple << [:newline]
        end
      end
    end

    def need_newline?(parent, child)
      if parent.is_a?(Ast::Element) && parent.nuke_inner_whitespace && parent.children.last.equal?(child)
        return false
      end
      case child
      when Ast::Script
        child.children.empty?
      when Ast::SilentScript, Ast::HamlComment
        false
      when Ast::Element
        !child.nuke_outer_whitespace
      else
        true
      end
    end

    def compile_text(ast)
      @text_compiler.compile(ast.text)
    end

    def compile_doctype(ast)
      [:html, :doctype, 'html']
    end

    def compile_html_comment(ast)
      if ast.children.empty?
        [:html, :comment, [:static, " #{ast.comment} "]]
      else
        temple = [:multi, [:static, "\n"]]
        compile_children(ast, temple)
        [:multi, [:html, :comment, temple]]
      end
    end

    def compile_element(ast)
      temple = [:html, :tag, ast.tag_name, ast.self_closing]
      html_attrs = [:html, :attrs]
      temple << html_attrs

      if ast.old_attributes.empty?
        unless ast.static_class.empty?
          html_attrs << [:html, :attr, 'class', [:static, ast.static_class]]
        end
        unless ast.static_id.empty?
          html_attrs << [:html, :attr, 'id', [:static, ast.static_id]]
        end
      else
        html_attrs.concat(compile_old_attributes(ast.old_attributes, ast.static_id, ast.static_class))
      end

      if ast.oneline_child
         temple << compile(ast.oneline_child)
      elsif !ast.children.empty?
        children = [:multi]
        unless ast.nuke_inner_whitespace
          children << [:static, "\n"]
        end
        children << [:newline]
        compile_children(ast, children)
        temple << children
      end

      temple
    end

    def compile_old_attributes(text, static_id, static_class)
      if attrs = try_optimize_attributes(text, static_id, static_class)
        return attrs
      end

      # Slow version

      attrs = [[:haml, :attr, text]]
      h = {}
      unless static_class.empty?
        h[:class] = static_class.split(/ +/)
      end
      unless static_id.empty?
        h[:id] = static_id
      end
      unless h.empty?
        t = h.inspect
        t << ", " << text
        text.replace(t)
      end
      attrs
    end

    SPECIAL_ATTRIBUTES = %w[id class data].freeze

    def try_optimize_attributes(text, static_id, static_class)
      parser = StaticHashParser.new
      unless parser.parse("{#{text}}")
        return nil
      end

      static_attributes = {}
      parser.static_attributes.each do |k, v|
        static_attributes[k.to_s] = v;
      end
      unless static_class.empty?
        static_attributes['class'] = [static_class.split(/ +/), static_attributes['class']].compact.flatten.sort.join(' ')
      end
      unless static_id.empty?
        static_attributes['id'] = [static_id, static_attributes['id']].compact.join('_')
      end

      dynamic_attributes = {}
      parser.dynamic_attributes.each do |k, v|
        k = k.to_s
        if static_attributes.has_key?(k)
          if SPECIAL_ATTRIBUTES.include?(k)
            # XXX: Quit optimization
            return nil
          end
        end
        dynamic_attributes[k] = v
      end

      if dynamic_attributes.has_key?('data')
        # XXX: Quit optimization...
        return nil
      end

      attrs = []
      keys = static_attributes.keys + dynamic_attributes.keys
      keys.sort.each do |k|
        if static_attributes.has_key?(k)
          v = static_attributes[k]
          if v == true
            attrs << [:html, :attr, k, [:multi]]
          elsif v.is_a?(Hash) && k == 'data'
            data = AttributeNormalizer.normalize_data(v)
            data.keys.sort.each do |k2|
              attrs << [:html, :attr, "data-#{k2}", [:static, Temple::Utils.escape_html(data[k2])]]
            end
          else
            attrs << [:html, :attr, k, [:static, Temple::Utils.escape_html(v)]]
          end
        else
          v = dynamic_attributes[k]
          attrs << [:html, :attr, k, [:escape, true, [:dynamic, v]]]
        end
      end
      attrs
    end

    def compile_script(ast)
      sym = unique_name
      temple = [:multi, [:code, "#{sym} = #{ast.script}"], [:newline]]
      compile_children(ast, temple)
      if !ast.children.empty? && !ast.mid_block_keyword
        temple << [:code, 'end']
      end
      temple << [:escape, true, [:dynamic, sym]]
      temple
    end

    def compile_silent_script(ast)
      temple = [:multi, [:code, ast.script], [:newline]]
      compile_children(ast, temple)
      if !ast.children.empty? && !ast.mid_block_keyword
        temple << [:code, 'end']
      end
      temple
    end

    def compile_filter(ast)
      FilterCompilers.find(ast.name).compile(ast.texts)
    end
  end
end
