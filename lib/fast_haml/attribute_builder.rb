module FastHaml
  module AttributeBuilder
    class << self
      def build(attr_quote, *hashes)
        attributes = { 'class' => [], 'id' => [] }
        merge(attributes, *hashes)

        attributes.keys.sort.map do |k|
          v = attributes[k]
          if k == 'class'
            if v.empty?
              ''
            else
              put_attr(attr_quote, 'class', v.map(&:to_s).sort.join(' '))
            end
          elsif k == 'id'
            if v.empty?
              ''
            else
              put_attr(attr_quote, 'id', v.map(&:to_s).join('_'))
            end
          elsif v == true
            " #{k}"
          else
            put_attr(attr_quote, k, v)
          end
        end.join
      end

      private

      def merge(attributes, *hashes)
        hashes.each do |h|
          h2 = {}
          h.keys.each do |k|
            h2[k.to_s] = h[k]
          end

          if h2.has_key?('class')
            attributes['class'].concat(Array(h2.delete('class')))
          end
          if h2.has_key?('id')
            attributes['id'].concat(Array(h2.delete('id')))
          end
          attributes.merge!(normalize(h2))
        end
        nil
      end

      def normalize(attrs)
        {}.tap do |h|
          attrs.each do |k, v|
            if v.is_a?(Hash) && k == 'data'
              data = AttributeNormalizer.normalize_data(v)
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

      def put_attr(attr_quote, key, val)
        " #{key}=#{attr_quote}#{Temple::Utils.escape_html(val)}#{attr_quote}"
      end
    end
  end
end
