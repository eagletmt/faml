require 'parser/current'

module FastHaml
  class StaticHashParser
    FAILURE_TAG = :failure

    attr_reader :static_attributes, :dynamic_attributes

    def initialize
      @static_attributes = {}
      @dynamic_attributes = {}
    end

    def parse(text)
      parser = ::Parser::CurrentRuby.new
      parser.diagnostics.consumer = nil
      buffer = ::Parser::Source::Buffer.new('(fast_haml)')
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

    def try_static_key(node)
      case node.type
      when :sym
        node.location.expression.source.gsub(/\A:/, '').to_sym
      when :int, :float, :str
        eval(node.location.expression.source)
      end
    end

    def try_static_value(key_static, node)
      case node.type
      when :sym
        @static_attributes[key_static] = node.location.expression.source.gsub(/\A:/, '').to_sym
      when :true, :false, :nil, :int, :float, :str
        @static_attributes[key_static] = eval(node.location.expression.source)
      when :dstr
        @dynamic_attributes[key_static] = node.location.expression.source
      when :hash
        parser = self.class.new
        if parser.walk(node)
          unless parser.static_attributes.empty?
            @static_attributes[key_static] = parser.static_attributes
          end
          unless parser.dynamic_attributes.empty?
            @dynamic_attributes[key_static] = parser.dynamic_attributes
          end
        else
          # TODO: Is it really impossible to optimize?
          throw FAILURE_TAG
        end
        # TODO: Add array case
      else
        throw FAILURE_TAG
      end
    end
  end
end
