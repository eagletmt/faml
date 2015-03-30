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
      parser = ::Parser::CurrentRuby.new
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

      if key_static = try_static_key(key)
        try_static_value(key_static, val)
      else
        throw FAILURE_TAG
      end
    end

    SYMBOL_FIRST_CHARS = [
      ':',  # { :'foo' => 'bar' } or { :"foo" => 'bar' }
      "'",  # { 'foo': 'bar' }
      '"',  # { "foo": 'bar' }
    ].freeze

    def eval_symbol(code)
      if SYMBOL_FIRST_CHARS.include?(code[0])
        eval(code).to_sym
      else
        code.to_sym
      end
    end

    def try_static_key(node)
      case node.type
      when :sym
        eval_symbol(node.location.expression.source)
      when :int, :float, :str
        eval(node.location.expression.source)
      end
    end

    def try_static_value(key_static, node)
      case node.type
      when :sym
        @static_attributes[key_static] = eval_symbol(node.location.expression.source)
      when :true, :false, :nil, :int, :float, :str
        @static_attributes[key_static] = eval(node.location.expression.source)
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
        # TODO: Add array case
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
  end
end
