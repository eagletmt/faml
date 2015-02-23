require 'temple'
require 'fast_haml/ast'
require 'fast_haml/filter_compilers'
require 'fast_haml/static_hash_parser'
require 'fast_haml/text_compiler'

module FastHaml
  class Compiler < Temple::Parser
    DEFAULT_AUTO_CLOSE_TAGS = %w[
      area base basefont br col command embed frame hr img input isindex keygen
      link menuitem meta param source track wbr
    ]
    DEFAULT_PRESERVE_TAGS = %w[pre textarea code]

    define_options(
      autoclose: DEFAULT_AUTO_CLOSE_TAGS,
      format: :html,
      preserve: DEFAULT_PRESERVE_TAGS,
    )

    def initialize(*)
      super
      @text_compiler = TextCompiler.new
    end

    def call(ast)
      compile(ast)
    end

    def self.find_and_preserve(input)
      # Taken from the original haml code
      re = /<(#{options[:preserve].map(&Regexp.method(:escape)).join('|')})([^>]*)>(.*?)(<\/\1>)/im
      input.to_s.gsub(re) do |s|
        s =~ re # Can't rely on $1, etc. existing since Rails' SafeBuffer#gsub is incompatible
        "<#{$1}#{$2}>#{preserve($3)}</#{$1}>"
      end
    end

    def self.preserve(input)
      # Taken from the original haml code
      input.to_s.chomp("\n").gsub(/\n/, '&#x000A;').gsub(/\r/, '')
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
      [:multi].tap do |temple|
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
          unless suppress_code_newline?(c.oneline_child)
            temple << [:newline]
          end
        end
        temple << compile(c)
        if was_newline = need_newline?(ast, c)
          temple << [:static, "\n"]
        end
        unless suppress_code_newline?(c)
          temple << [:newline]
        end
      end
    end

    def need_newline?(parent, child)
      if parent.is_a?(Ast::Element) && nuke_inner_whitespace?(parent) && parent.children.last.equal?(child)
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

    def suppress_code_newline?(ast)
      ast.is_a?(Ast::Script) || ast.is_a?(Ast::SilentScript) || (ast.is_a?(Ast::Element) && suppress_code_newline?(ast.oneline_child))
    end

    def compile_text(ast)
      @text_compiler.compile(ast.text, escape_html: ast.escape_html)
    end

    # html5 and html4 is deprecated in temple.
    DEFAULT_DOCTYPE = {
      html: 'html',
      html5: 'html',
      html4: 'transitional',
      xhtml: 'transitional',
    }.freeze

    def compile_doctype(ast)
      doctype = ast.doctype.downcase
      if doctype.empty?
        doctype = DEFAULT_DOCTYPE[options[:format]]
      end
      [:haml, :doctype, doctype]
    end

    def compile_html_comment(ast)
      if ast.children.empty?
        if ast.conditional.empty?
          [:html, :comment, [:static, " #{ast.comment} "]]
        else
          [:html, :comment, [:static, "[#{ast.conditional}]> #{ast.comment} <![endif]"]]
        end
      else
        temple = [:multi]
        if ast.conditional.empty?
          temple << [:static, "\n"]
        else
          temple << [:static, "[#{ast.conditional}]>\n"]
        end
        compile_children(ast, temple)
        unless ast.conditional.empty?
          temple << [:static, "<![endif]"]
        end
        [:multi, [:html, :comment, temple]]
      end
    end

    def compile_element(ast)
      temple = [
        :haml, :tag,
        ast.tag_name,
        self_closing?(ast),
        compile_attributes(ast.attributes, ast.static_id, ast.static_class),
      ]

      if ast.oneline_child
         temple << compile(ast.oneline_child)
      elsif !ast.children.empty?
        children = [:multi]
        unless nuke_inner_whitespace?(ast)
          children << [:static, "\n"]
        end
        compile_children(ast, children)
        temple << children
      end

      temple
    end

    def self_closing?(ast)
      ast.self_closing || options[:autoclose].include?(ast.tag_name)
    end

    def nuke_inner_whitespace?(ast)
      ast.nuke_inner_whitespace || options[:preserve].include?(ast.tag_name)
    end

    def compile_attributes(text, static_id, static_class)
      if text.empty?
        return compile_static_id_and_class(static_id, static_class)
      end

      if attrs = try_optimize_attributes(text, static_id, static_class)
        return [:html, :attrs, *attrs]
      end

      # Slow version

      h = {}
      unless static_class.empty?
        h[:class] = static_class.split(/ +/)
      end
      unless static_id.empty?
        h[:id] = static_id
      end

      t =
        if h.empty?
          text
        else
          "#{h.inspect}, #{text}"
        end
      [:haml, :attrs, t]
    end

    def compile_static_id_and_class(static_id, static_class)
      [:html, :attrs].tap do |html_attrs|
        unless static_class.empty?
          html_attrs << [:haml, :attr, 'class', [:static, static_class]]
        end
        unless static_id.empty?
          html_attrs << [:haml, :attr, 'id', [:static, static_id]]
        end
      end
    end

    def try_optimize_attributes(text, static_id, static_class)
      parser = StaticHashParser.new
      unless parser.parse("{#{text}}")
        return nil
      end

      static_attributes, dynamic_attributes = build_optimized_attributes(parser, static_id, static_class)
      if static_attributes.nil?
        return nil
      end

      if dynamic_attributes.has_key?('data')
        # XXX: Quit optimization...
        return nil
      end

      (static_attributes.keys + dynamic_attributes.keys).sort.flat_map do |k|
        if static_attributes.has_key?(k)
          compile_static_attribute(k, static_attributes[k])
        else
          compile_dynamic_attribute(k, dynamic_attributes[k])
        end
      end
    end

    def build_optimized_attributes(parser, static_id, static_class)
      static_attributes = {}
      parser.static_attributes.each do |k, v|
        static_attributes[k.to_s] = v
      end
      unless static_class.empty?
        static_attributes['class'] = [static_class.split(/ +/), static_attributes['class']].compact.flatten.map(&:to_s).sort.join(' ')
      end
      unless static_id.empty?
        static_attributes['id'] = [static_id, static_attributes['id']].compact.join('_')
      end

      dynamic_attributes = {}
      parser.dynamic_attributes.each do |k, v|
        k = k.to_s
        if static_attributes.has_key?(k)
          if StaticHashParser::SPECIAL_ATTRIBUTES.include?(k)
            # XXX: Quit optimization
            return [nil, nil]
          end
        end
        dynamic_attributes[k] = v
      end

      [static_attributes, dynamic_attributes]
    end

    def compile_static_attribute(key, value)
      case
      when value == true
        [[:haml, :attr, key, [:multi]]]
      when value.is_a?(Hash) && key == 'data'
        data = AttributeBuilder.normalize_data(value)
        data.keys.sort.map do |k|
          [:haml, :attr, "data-#{k}", [:static, Temple::Utils.escape_html(data[k])]]
        end
      else
        [[:haml, :attr, key, [:static, Temple::Utils.escape_html(value)]]]
      end
    end

    def compile_dynamic_attribute(key, value)
      [[:haml, :attr, key, [:escape, true, [:dynamic, value]]]]
    end

    def compile_script(ast)
      sym = unique_name
      temple = [:multi, [:code, "#{sym} = #{ast.script}"], [:newline]]
      compile_children(ast, temple)
      if !ast.children.empty? && !ast.mid_block_keyword
        temple << [:code, 'end']
      end
      if !ast.escape_html && ast.preserve
        temple << [:haml, :preserve, sym]
      else
        temple << [:escape, ast.escape_html, [:dynamic, "#{sym}.to_s"]]
      end
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
