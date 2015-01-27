module FastHaml
  class AttributeBuilder
    def initialize(options)
      @attributes = {}
      @options = options
    end

    def merge!(*hashes)
      @attributes.merge!(*hashes.map { |h| normalize(h) })
    end

    def build
      @attributes.keys.sort.map do |k|
        v = @attributes[k]
        if v == true
          " #{k}"
        else
          " #{k}=#{@options[:attr_quote]}#{Temple::Utils.escape_html(v)}#{@options[:attr_quote]}"
        end
      end.join
    end

    private

    def normalize(attrs)
      h = {}
      attrs.each do |k, v|
        if v.is_a?(Hash)
          normalize(v).each do |k2, v2|
            h["#{k}-#{k2}"] = v2
          end
        else
          h[k.to_s] = v
        end
      end
      h
    end
  end
end
