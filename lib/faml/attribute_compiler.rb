require_relative 'error'
require_relative 'object_ref'
require_relative 'ruby_syntax_checker'
require_relative 'static_hash_parser'

module Faml
  class AttributeCompiler
    def compile(ast)
      if !ast.object_ref && ast.attributes.empty?
        return compile_static_id_and_class(ast.static_id, ast.static_class)
      end

      unless ast.object_ref
        attrs = try_optimize_attributes(ast.attributes, ast.static_id, ast.static_class)
        if attrs
          line_count = ast.attributes.count("\n")
          return [:multi, [:html, :attrs, *attrs]].concat([[:newline]] * line_count)
        end
      end

      compile_slow_attributes(ast.attributes, ast.static_id, ast.static_class, ast.object_ref)
    end

    private

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

      class_list = Array(static_attributes.delete('class')).select { |v| v }.flat_map { |c| c.to_s.split(/ +/) }
      unless static_class.empty?
        class_list.concat(static_class.split(/ +/))
      end
      unless class_list.empty?
        static_attributes['class'] = class_list.uniq.sort.join(' ')
      end

      id_list = Array(static_attributes.delete('id')).select { |v| v }
      unless static_id.empty?
        id_list = [static_id].concat(id_list)
      end
      unless id_list.empty?
        static_attributes['id'] = id_list.join('_')
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

    def compile_slow_attributes(text, static_id, static_class, object_ref)
      h = {}
      unless static_class.empty?
        h[:class] = static_class.split(/ +/)
      end
      unless static_id.empty?
        h[:id] = static_id
      end

      codes = []
      unless h.empty?
        codes << h.inspect
      end
      if object_ref
        codes << "::Faml::ObjectRef.render(#{object_ref})"
      end
      unless text.empty?
        codes << text
      end
      [:haml, :attrs, codes.join(', ')]
    end
  end
end
