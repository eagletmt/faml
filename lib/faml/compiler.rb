require 'ripper'
require 'temple'
require 'haml_parser/ast'
require_relative 'error'
require_relative 'filter_compilers'
require_relative 'helpers'
require_relative 'rails_helpers'
require_relative 'ruby_syntax_checker'
require_relative 'static_hash_parser'
require_relative 'text_compiler'

module Faml
  class Compiler < Temple::Parser
    class UnparsableRubyCode < Error
    end

    DEFAULT_AUTO_CLOSE_TAGS = %w[
      area base basefont br col command embed frame hr img input isindex keygen
      link menuitem meta param source track wbr
    ]
    DEFAULT_PRESERVE_TAGS = %w[pre textarea code]

    define_options(
      autoclose: DEFAULT_AUTO_CLOSE_TAGS,
      format: :html,
      preserve: DEFAULT_PRESERVE_TAGS,
      use_html_safe: false,
      filename: nil,
    )

    def initialize(*)
      super
      @text_compiler = TextCompiler.new
      @filename = options[:filename]
    end

    def call(ast)
      compile(ast)
    rescue Error => e
      if @filename && e.lineno
        e.backtrace.unshift "#{@filename}:#{e.lineno}"
      end
      raise e
    end

    def self.find_and_preserve(input)
      # Taken from the original haml code
      re = %r{<(#{options[:preserve].map(&Regexp.method(:escape)).join('|')})([^>]*)>(.*?)(<\/\1>)}im
      input.to_s.gsub(re) do |s|
        m = s.match(re) # Can't rely on $1, etc. existing since Rails' SafeBuffer#gsub is incompatible
        "<#{m[1]}#{m[2]}>#{Helpers.preserve(m[3])}</#{m[1]}>"
      end
    end

    private

    def compile(ast)
      case ast
      when HamlParser::Ast::Root
        compile_root(ast)
      when HamlParser::Ast::Doctype
        compile_doctype(ast)
      when HamlParser::Ast::HtmlComment
        compile_html_comment(ast)
      when HamlParser::Ast::HamlComment
        compile_haml_comment(ast)
      when HamlParser::Ast::Empty
        [:multi]
      when HamlParser::Ast::Element
        compile_element(ast)
      when HamlParser::Ast::Script
        compile_script(ast)
      when HamlParser::Ast::SilentScript
        compile_silent_script(ast)
      when HamlParser::Ast::Text
        compile_text(ast)
      when HamlParser::Ast::Filter
        compile_filter(ast)
      else
        raise "InternalError: Unknown AST node #{ast.class}: #{ast.inspect}"
      end
    end

    def compile_root(ast)
      [:multi, [:code, "extend ::#{helper_module.name}"]].tap do |temple|
        compile_children(ast, temple)
      end
    end

    def helper_module
      if options[:use_html_safe]
        RailsHelpers
      else
        Helpers
      end
    end

    def compile_children(ast, temple)
      ast.children.each do |c|
        temple << compile(c)
        if need_newline?(c)
          temple << [:mknl]
        end
        unless suppress_code_newline?(c)
          temple << [:newline]
        end
      end
    end

    def need_newline?(child)
      case child
      when HamlParser::Ast::Script
        child.children.empty?
      when HamlParser::Ast::SilentScript, HamlParser::Ast::HamlComment, HamlParser::Ast::Empty
        false
      when HamlParser::Ast::Element
        !child.nuke_outer_whitespace
      when HamlParser::Ast::Filter
        FilterCompilers.find(child.name).need_newline?
      else
        true
      end
    end

    def suppress_code_newline?(ast)
      ast.is_a?(HamlParser::Ast::Script) ||
        ast.is_a?(HamlParser::Ast::SilentScript) ||
        (ast.is_a?(HamlParser::Ast::Element) && suppress_code_newline?(ast.oneline_child)) ||
        (ast.is_a?(HamlParser::Ast::Element) && !ast.children.empty?) ||
        (ast.is_a?(HamlParser::Ast::HtmlComment) && !ast.conditional.empty?)
    end

    def compile_text(ast)
      @text_compiler.compile(ast.text, ast.lineno, escape_html: ast.escape_html)
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
          temple << [:mknl]
        else
          temple << [:static, "[#{ast.conditional}]>"] << [:mknl] << [:newline]
        end
        compile_children(ast, temple)
        unless ast.conditional.empty?
          temple << [:static, '<![endif]']
        end
        [:multi, [:html, :comment, temple]]
      end
    end

    def compile_haml_comment(ast)
      [:multi].concat([[:newline]] * ast.children.size)
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
        temple << compile_element_children(ast)
      end

      if ast.nuke_outer_whitespace
        [:multi, [:rmnl], temple]
      else
        temple
      end
    rescue UnparsableRubyCode => e
      unless e.lineno
        e.lineno = ast.lineno
      end
      raise e
    end

    def self_closing?(ast)
      ast.self_closing || options[:autoclose].include?(ast.tag_name)
    end

    def compile_element_children(ast)
      children = [:multi]
      unless nuke_inner_whitespace?(ast)
        children << [:mknl]
      end
      children << [:newline]
      compile_children(ast, children)
      if nuke_inner_whitespace?(ast)
        children << [:rmnl]
      end
      children
    end

    def nuke_inner_whitespace?(ast)
      ast.nuke_inner_whitespace || options[:preserve].include?(ast.tag_name)
    end

    def compile_attributes(text, static_id, static_class)
      if text.empty?
        return compile_static_id_and_class(static_id, static_class)
      end

      attrs = try_optimize_attributes(text, static_id, static_class)
      if attrs
        line_count = text.count("\n")
        return [:multi, [:html, :attrs, *attrs]].concat([[:newline]] * line_count)
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
        assert_valid_ruby_code!(text)
        return nil
      end

      static_attributes, dynamic_attributes = build_optimized_attributes(parser, static_id, static_class)
      if static_attributes.nil?
        return nil
      end

      if dynamic_attributes.key?('data')
        # XXX: Quit optimization...
        return nil
      end

      if text.include?("\n") && !dynamic_attributes.empty?
        # XXX: Quit optimization to keep newlines
        # https://github.com/eagletmt/faml/issues/18
        return nil
      end

      (static_attributes.keys + dynamic_attributes.keys).sort.flat_map do |k|
        if static_attributes.key?(k)
          compile_static_attribute(k, static_attributes[k])
        else
          compile_dynamic_attribute(k, dynamic_attributes[k])
        end
      end
    end

    def assert_valid_ruby_code!(text)
      RubySyntaxChecker.new("call(#{text})", '(faml)').parse
      true
    rescue RubySyntaxChecker::Error
      raise UnparsableRubyCode.new("Unparsable Ruby code is given to attributes: #{text}", nil)
    end

    def build_optimized_attributes(parser, static_id, static_class)
      static_attributes = build_optimized_static_attributes(parser, static_id, static_class)
      dynamic_attributes = build_optimized_dynamic_attributes(parser, static_attributes)
      if dynamic_attributes
        [static_attributes, dynamic_attributes]
      else
        [nil, nil]
      end
    end

    def build_optimized_static_attributes(parser, static_id, static_class)
      static_attributes = {}
      parser.static_attributes.each do |k, v|
        static_attributes[k.to_s] = v
      end
      unless static_class.empty?
        class_list = static_attributes.fetch('class', '').to_s.split(/ +/)
        static_attributes['class'] = static_class.split(/ +/).concat(class_list).uniq.sort.join(' ')
      end
      unless static_id.empty?
        static_attributes['id'] = [static_id, static_attributes['id']].compact.join('_')
      end
      static_attributes
    end

    def build_optimized_dynamic_attributes(parser, static_attributes)
      dynamic_attributes = {}
      parser.dynamic_attributes.each do |k, v|
        k = k.to_s
        if static_attributes.key?(k)
          if StaticHashParser::SPECIAL_ATTRIBUTES.include?(k)
            # XXX: Quit optimization
            return nil
          end
        end
        dynamic_attributes[k] = v
      end
      dynamic_attributes
    end

    def compile_static_attribute(key, value)
      if value.is_a?(Hash) && key == 'data'
        data = AttributeBuilder.normalize_data(value)
        data.keys.sort.map do |k|
          compile_static_simple_attribute("data-#{k}", data[k])
        end
      else
        [compile_static_simple_attribute(key, value)]
      end
    end

    def compile_static_simple_attribute(key, value)
      case
      when value == true
        [:haml, :attr, key, [:multi]]
      when value == false || value.nil?
        [:multi]
      else
        [:haml, :attr, key, [:static, Temple::Utils.escape_html(value)]]
      end
    end

    def compile_dynamic_attribute(key, value)
      [[:haml, :attr, key, [:dvalue, value]]]
    end

    def compile_script(ast)
      sym = unique_name
      temple = [:multi]
      if ast.children.empty?
        temple << [:code, "#{sym} = (#{ast.script}"] << [:newline] << [:code, ')']
      else
        temple << [:code, "#{sym} = #{ast.script}"] << [:newline]
        compile_children(ast, temple)
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
      FilterCompilers.find(ast.name).compile(ast)
    rescue FilterCompilers::NotFound => e
      unless e.lineno
        e.lineno = ast.lineno
      end
      raise e
    end
  end
end
