require 'singleton'

module FastHaml
  class AttributeBuilder
    include Singleton

    def init(options)
      @attributes = {}
      @options = options
    end

    def merge!(*hashes)
      @attributes.merge!(*hashes.map { |h| normalize(h) })
    end

    def build!
      @attributes.keys.sort.map do |k|
        v = @attributes[k]
        if v == true
          " #{k}"
        else
          " #{k}=#{@options[:attr_quote]}#{Temple::Utils.escape_html(v)}#{@options[:attr_quote]}"
        end
      end.join.tap do
        @attributes.clear
      end
    end

    private

    def normalize(attrs)
      {}.tap do |h|
        attrs.each do |k, v|
          k = k.to_s
          if v.is_a?(Hash) && k == 'data'
            data = AttributeNormalizer.normalize_data(v)
            data.keys.sort.each do |k2|
              h["data-#{k2}"] = data[k2]
            end
          else
            h[k] = v.to_s
          end
        end
      end
    end
  end
end
