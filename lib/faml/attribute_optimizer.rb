# frozen-string-literal: true
require 'faml/attribute_builder'
require_relative 'error'
require_relative 'ruby_syntax_checker'
require_relative 'static_hash_parser'

module Faml
  class AttributeOptimizer
    def try_optimize(old_attributes, new_attributes, static_id, static_class)
      parser = StaticHashParser.new
      unless parser.parse("{#{new_attributes}#{old_attributes}}")
        assert_valid_ruby_code!(old_attributes)
        return [nil, nil]
      end
      if old_attributes && new_attributes
        # TODO: Quit optimization. Merge id and class correctly.
        return [nil, nil]
      end

      static_attributes, dynamic_attributes = build_optimized_attributes(parser, static_id, static_class)
      if optimizable?(old_attributes, new_attributes, static_attributes, dynamic_attributes)
        [static_attributes, dynamic_attributes]
      else
        [nil, nil]
      end
    end

    private

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
      if static_id.empty?
        static_id = nil
      end
      if static_class.empty?
        static_class = nil
      end
      AttributeBuilder.merge(parser.static_attributes, id: static_id, class: static_class)
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

    def optimizable?(old_attributes, new_attributes, static_attributes, dynamic_attributes)
      if static_attributes.nil?
        return false
      end

      if dynamic_attributes.key?('data')
        # XXX: Quit optimization...
        return false
      end

      old_newline = old_attributes && old_attributes.include?("\n")
      new_newline = new_attributes && new_attributes.include?("\n")
      if (old_newline || new_newline) && !dynamic_attributes.empty?
        # XXX: Quit optimization to keep newlines
        # https://github.com/eagletmt/faml/issues/18
        return false
      end

      true
    end
  end
end
