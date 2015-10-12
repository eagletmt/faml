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

    def try_static_value(key_static, node)
      case node.type
      when :sym, :int, :float, :str, :rational, :complex
        @static_attributes[key_static] = node.children[0]
      when :true
        @static_attributes[key_static] = true
      when :false
        @static_attributes[key_static] = false
      when :nil
        @static_attributes[key_static] = nil
      when :dstr
        @dynamic_attributes[key_static] = node.location.expression.source
      when :send
        if SPECIAL_ATTRIBUTES.include?(key_static.to_s)
          throw FAILURE_TAG
        else
          @dynamic_attributes[key_static] = node.location.expression.source
        end
      when :hash
        try_static_hash_value(key_static, node)
      when :array
        try_static_array_value(key_static, node)
      else
        throw FAILURE_TAG
      end
    end

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
        @static_attributes[key_static] = parser.static_attributes
      end

      unless parser.dynamic_attributes.empty?
        expr = parser.dynamic_attributes.map do |k, v|
          "#{k.inspect} => #{v}"
        end.join(', ')
        @dynamic_attributes[key_static] = "{#{expr}}"
      end
    end

    def try_static_array_value(key_static, node)
      arr = node.children.map do |child|
        try_static_value(key_static, child)
      end
      @static_attributes[key_static] = arr
    end
  end
end
