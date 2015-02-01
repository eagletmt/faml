require 'temple'
require 'fast_haml/ast'
require 'fast_haml/attribute_normalizer'
require 'fast_haml/static_hash_parser'

module FastHaml
  class Compiler < Temple::Parser
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
      when Ast::Element
        compile_element(ast)
      when Ast::Script
        compile_script(ast)
      when Ast::SilentScript
        compile_silent_script(ast)
      when Ast::Text
        compile_text(ast)
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
      ast.children.each do |c|
        temple << compile(c)
        if need_newline?(c)
          temple << [:static, "\n"]
          temple << [:newline]
        end
      end
    end

    def need_newline?(ast)
      case ast
      when Ast::Script
        ast.children.empty?
      when Ast::SilentScript
        false
      else
        true
      end
    end

    def compile_text(ast)
      [:static, ast.text]
    end

    def compile_doctype(ast)
      [:html, :doctype, 'html']
    end

    def compile_html_comment(ast)
      [:html, :comment, [:static, " #{ast.comment} "]]
    end

    def compile_element(ast)
      temple = [:html, :tag, ast.tag_name]
      html_attrs = [:html, :attrs]
      temple << html_attrs

      unless ast.static_class.empty?
        html_attrs << [:html, :attr, 'class', [:static, ast.static_class]]
      end
      unless ast.static_id.empty?
        html_attrs << [:html, :attr, 'id', [:static, ast.static_id]]
      end
      unless ast.old_attributes.empty?
        html_attrs.concat(compile_old_attributes(ast.old_attributes))
      end

      if ast.oneline_child
         temple << compile(ast.oneline_child)
      elsif !ast.children.empty?
        children = [:multi, [:static, "\n"], [:newline]]
        compile_children(ast, children)
        temple << children
      end

      temple
    end

    def compile_old_attributes(text)
      attrs = []
      parser = StaticHashParser.new
      if parser.parse("{#{text}}")
        static_attributes = {}
        parser.static_attributes.each do |k, v|
          static_attributes[k.to_s] = v;
        end
        dynamic_attributes = {}
        parser.dynamic_attributes.each do |k, v|
          dynamic_attributes[k.to_s] = v
        end

        if dynamic_attributes.has_key?('data')
          # XXX: Quit optimization...
          attrs << [:haml, :attr, text]
        else
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
        end
      else
        attrs << [:haml, :attr, text]
      end
      attrs
    end

    def compile_script(ast)
      sym = unique_name
      temple = [:multi, [:code, "#{sym} = #{ast.script}"], [:newline]]
      compile_children(ast, temple)
      temple << [:dynamic, sym]
      temple
    end

    def compile_silent_script(ast)
      temple = [:multi, [:code, ast.script]]
      compile_children(ast, temple)
      temple
    end
  end
end
