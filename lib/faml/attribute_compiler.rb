# frozen_string_literal: true
require_relative 'attribute_optimizer'
require_relative 'object_ref'

module Faml
  class AttributeCompiler
    def compile(ast)
      if !ast.object_ref && !ast.old_attributes && !ast.new_attributes
        return compile_static_id_and_class(ast.static_id, ast.static_class)
      end

      unless ast.object_ref
        attrs = try_optimize_attributes(ast.old_attributes, ast.new_attributes, ast.static_id, ast.static_class)
        if attrs
          line_count = 0
          if ast.old_attributes
            line_count += ast.old_attributes.count("\n")
          end
          if ast.new_attributes
            line_count += ast.new_attributes.count("\n")
          end
          return [:multi, [:html, :attrs, *attrs]].concat([[:newline]] * line_count)
        end
      end

      compile_slow_attributes(ast.old_attributes, ast.new_attributes, ast.static_id, ast.static_class, ast.object_ref)
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

    def try_optimize_attributes(old_attributes, new_attributes, static_id, static_class)
      static_attributes, dynamic_attributes = AttributeOptimizer.new.try_optimize(old_attributes, new_attributes, static_id, static_class)
      if static_attributes
        (static_attributes.keys + dynamic_attributes.keys).sort.map do |k|
          if static_attributes.key?(k)
            compile_static_attribute(k, static_attributes[k])
          else
            compile_dynamic_attribute(k, dynamic_attributes[k])
          end
        end
      end
    end

    def compile_static_attribute(key, value)
      if value == true
        [:haml, :attr, key, [:multi]]
      else
        [:haml, :attr, key, [:static, Temple::Utils.escape_html(value)]]
      end
    end

    def compile_dynamic_attribute(key, value)
      [:haml, :attr, key, [:dvalue, value]]
    end

    def compile_slow_attributes(old_attributes, new_attributes, static_id, static_class, object_ref)
      h = {}
      unless static_class.empty?
        h[:class] = static_class
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
      if new_attributes
        codes << "{#{new_attributes}}"
      end
      if old_attributes
        codes << old_attributes
      end
      [:haml, :attrs, codes.join(', ')]
    end
  end
end
