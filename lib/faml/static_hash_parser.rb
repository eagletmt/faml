require 'parser/current'

module Faml
  class StaticHashParser
    FAILURE_TAG = :failure

    SPECIAL_ATTRIBUTES = %w[id class data].freeze

    attr_reader :static_attributes, :dynamic_attributes

    def initialize
      @static_attributes = {}
      @dynamic_attributes = {}
    end

    def parse(text)
      builder = ::Parser::Builders::Default.new
      builder.emit_file_line_as_literals = false
      parser = ::Parser::CurrentRuby.new(builder)
      parser.diagnostics.consumer = nil
      buffer = ::Parser::Source::Buffer.new('(faml)')
      buffer.source = text
      walk(parser.parse(buffer))
    rescue ::Parser::SyntaxError
      false
    end

    def walk(node)
      catch(FAILURE_TAG) do
        walk_hash(node)
        return true
      end
      false
    end

    private

    def walk_hash(node)
      if node.type != :hash
        throw FAILURE_TAG
      end
      node.children.each do |pair|
        walk_pair(pair)
      end
    end

    def walk_pair(node)
      if node.type != :pair
        throw FAILURE_TAG
      end
      key = node.children[0]
      val = node.children[1]
      key_static = try_static_key(key)
      if key_static
        try_static_value(key_static, val)
      else
        throw FAILURE_TAG
      end
    end

    def try_static_key(node)
      case node.type
      when :sym, :int, :float, :str, :rational, :complex
        node.children[0]
      end
    end

    def try_static_value(key_static, node, force_static: false)
      case node.type
      when :sym, :int, :float, :str, :rational, :complex
        set_static_attribute(key_static, node.children[0])
      when :true
        set_static_attribute(key_static, true)
      when :false
        set_static_attribute(key_static, false)
      when :nil
        set_static_attribute(key_static, nil)
      when :dstr
        if force_static
          throw FAILURE_TAG
        end
        set_dynamic_attributes(key_static, node.location.expression.source)
      when :send
        if force_static
          throw FAILURE_TAG
        end
        set_dynamic_attributes(key_static, node.location.expression.source)
      when :hash
        try_static_hash_value(key_static, node)
      when :array
        try_static_array_value(key_static, node)
      else
        throw FAILURE_TAG
      end
    end
    protected :try_static_value

    def try_static_hash_value(key_static, node)
      parser = self.class.new
      if parser.walk(node)
        merge_attributes(key_static, parser)
      else
        # TODO: Is it really impossible to optimize?
        throw FAILURE_TAG
      end
    end

    def merge_attributes(key_static, parser)
      unless parser.static_attributes.empty?
        set_static_attribute(key_static, parser.static_attributes)
      end

      unless parser.dynamic_attributes.empty?
        expr = parser.dynamic_attributes.map do |k, v|
          "#{k.inspect} => #{v}"
        end.join(', ')
        @dynamic_attributes[key_static] = "{#{expr}}"
      end
    end

    def try_static_array_value(key_static, node)
      parser = self.class.new
      arr = node.children.map.with_index do |child, i|
        # TODO: Support dynamic_attributes?
        parser.try_static_value(i, child, force_static: true)
      end
      set_static_attribute(key_static, arr)
    end

    def set_static_attribute(key, val)
      case key.to_s
      when 'id', 'class'
        @static_attributes[key] ||= []
        @static_attributes[key].concat(Array(val))
      else
        @static_attributes[key] = val
      end
      val
    end

    def set_dynamic_attributes(key, val)
      if SPECIAL_ATTRIBUTES.include?(key.to_s)
        throw FAILURE_TAG
      end
      @dynamic_attributes[key] = val
    end
  end
end
