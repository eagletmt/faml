require_relative 'error'
require_relative 'ruby_syntax_checker'
require_relative 'static_hash_parser'

module Faml
  class AttributeOptimizer
    def try_optimize(text, static_id, static_class)
      parser = StaticHashParser.new
      unless parser.parse("{#{text}}")
        assert_valid_ruby_code!(text)
        return [nil, nil]
      end

      static_attributes, dynamic_attributes = build_optimized_attributes(parser, static_id, static_class)
      if optimizable?(text, static_attributes, dynamic_attributes)
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

    def optimizable?(text, static_attributes, dynamic_attributes)
      if static_attributes.nil?
        return false
      end

      if dynamic_attributes.key?('data')
        # XXX: Quit optimization...
        return false
      end

      if text.include?("\n") && !dynamic_attributes.empty?
        # XXX: Quit optimization to keep newlines
        # https://github.com/eagletmt/faml/issues/18
        return false
      end

      true
    end
  end
end
