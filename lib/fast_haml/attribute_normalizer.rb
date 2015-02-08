module FastHaml
  module AttributeNormalizer
    module_function

    def normalize_data(data)
      {}.tap do |h|
        data.each do |k1, v1|
          if v1.is_a?(Hash)
            normalize_data(v1).each do |k2, v2|
              h["#{k1}-#{k2}"] = v2
            end
          else
            h[k1.to_s] = v1
          end
        end
      end
    end
  end
end
