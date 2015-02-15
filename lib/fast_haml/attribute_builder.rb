module FastHaml
  module AttributeBuilder
    class << self
      def build(attr_quote, *hashes)
        attributes = { 'class' => [], 'id' => [] }
        merge(attributes, *hashes)

        attributes.keys.sort.map do |k|
          build_attribute(attr_quote, k, attributes[k])
        end.join
      end

      def normalize_data(data)
        {}.tap do |h|
          data.each do |k1, v1|
            if v1.is_a?(Hash)
              normalize_data(v1).each do |k2, v2|
                h["#{k1.to_s.gsub('_', '-')}-#{k2}"] = v2
              end
            else
              h[k1.to_s.gsub('_', '-')] = v1
            end
          end
        end
      end

      private

      def merge(attributes, *hashes)
        hashes.each do |h|
          h = stringify_keys(h)
          concat_array_attribute!(attributes, h, 'class')
          concat_array_attribute!(attributes, h, 'id')
          attributes.merge!(normalize(h))
        end
        nil
      end

      def stringify_keys(hash)
        {}.tap do |h|
          hash.keys.each do |k|
            h[k.to_s] = hash[k]
          end
        end
      end

      def concat_array_attribute!(attributes, hash, key)
        if hash.has_key?(key)
          attributes[key].concat(Array(hash.delete(key)))
        end
      end

      def normalize(attrs)
        {}.tap do |h|
          attrs.each do |k, v|
            if v.is_a?(Hash) && k == 'data'
              data = normalize_data(v)
              data.keys.sort.each do |k2|
                h["data-#{k2}"] = data[k2]
              end
            else
              if v == true
                h[k] = v
              else
                h[k] = v.to_s
              end
            end
          end
        end
      end

      def build_attribute(attr_quote, key, value)
        if key == 'class'
          build_array_attribute(attr_quote, 'class', value) do |values|
            values.sort.join(' ')
          end
        elsif key == 'id'
          build_array_attribute(attr_quote, 'id', value) do |values|
            values.join('_')
          end
        elsif value == true
          " #{key}"
        else
          put_attribute(attr_quote, key, value)
        end
      end

      def build_array_attribute(attr_quote, key, value)
        if value.empty?
          ''
        else
          put_attribute(attr_quote, key, yield(value.map(&:to_s)))
        end
      end

      def put_attribute(attr_quote, key, value)
        " #{key}=#{attr_quote}#{Temple::Utils.escape_html(value)}#{attr_quote}"
      end
    end
  end
end
