require 'singleton'

module FastHaml
  class AttributeBuilder
    include Singleton

    def init(options)
      @attributes = {
        'class' => [],
        'id' => [],
      }
      @options = options
    end

    def merge!(*hashes)
      hashes.each do |h|
        h2 = {}
        h.keys.each do |k|
          h2[k.to_s] = h[k]
        end

        if h2.has_key?('class')
          @attributes['class'].concat(Array(h2.delete('class')))
        end
        if h2.has_key?('id')
          @attributes['id'].concat(Array(h2.delete('id')))
        end
        @attributes.merge!(normalize(h2))
      end
      nil
    end

    def build!
      @attributes.keys.sort.map do |k|
        v = @attributes[k]
        if k == 'class'
          if v.empty?
            ''
          else
            put_attr('class', v.map(&:to_s).sort.join(' '))
          end
        elsif k == 'id'
          if v.empty?
            ''
          else
            put_attr('id', v.map(&:to_s).join('_'))
          end
        elsif v == true
          " #{k}"
        else
          put_attr(k, v)
        end
      end.join.tap do
        @attributes.clear
      end
    end

    private

    def normalize(attrs)
      {}.tap do |h|
        attrs.each do |k, v|
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

    def put_attr(key, val)
      " #{key}=#{@options[:attr_quote]}#{Temple::Utils.escape_html(val)}#{@options[:attr_quote]}"
    end
  end
end
