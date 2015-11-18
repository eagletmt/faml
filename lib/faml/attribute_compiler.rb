require_relative 'attribute_optimizer'
require_relative 'object_ref'

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
      static_attributes, dynamic_attributes = AttributeOptimizer.new.try_optimize(text, static_id, static_class)
      if static_attributes
        (static_attributes.keys + dynamic_attributes.keys).sort.flat_map do |k|
          if static_attributes.key?(k)
            compile_static_attribute(k, static_attributes[k])
          else
            compile_dynamic_attribute(k, dynamic_attributes[k])
          end
        end
      end
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
      if object_ref
        codes << "::Faml::ObjectRef.render(#{object_ref})"
      else
        codes << 'nil'
      end
      unless h.empty?
        codes << h.inspect
      end
      unless text.empty?
        codes << text
      end
      [:haml, :attrs, codes.join(', ')]
    end
  end
end
