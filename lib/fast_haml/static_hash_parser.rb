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
      walk(::Parser::CurrentRuby.parse(text))
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
        try_static_value(key_static.to_s, val)
      else
        throw FAILURE_TAG
      end
    end

    def try_static_key(node)
      case node.type
      when :sym
        node.location.expression.source.gsub(/\A:/, '')
      when :int, :float, :str
        eval(node.location.expression.source).to_s
      end
    end

    def try_static_value(key_static, node)
      case node.type
      when :sym
        @static_attributes[key_static] = node.location.expression.source
      when :true, :false, :nil, :int, :float, :str
        @static_attributes[key_static] = eval(node.location.expression.source)
      when :hash
        parser = self.class.new
        if parser.walk(node)
          parser.static_attributes.each do |k, v|
            @static_attributes["#{key_static}-#{k}"] = v
          end
          parser.dynamic_attributes.each do |k, v|
            @dynamic_attributes["#{key_static}-#{k}"] = v
          end
        else
          @dynamic_attributes[key_static] = node.location.expression.source
        end
        # TODO: Add dstr case
        # TODO: Add array case
      else
        @dynamic_attributes[key_static] = node.location.expression.source
      end
    end
  end
end
