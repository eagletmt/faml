require 'fast_haml/attribute_builder'

module FastHaml
  class Html < Temple::HTML::Fast
    def on_html_attrs(*attrs)
      if attrs.empty?
        [:multi]
      else
        @sym = unique_name
        [:multi,
         [:code, "#{@sym} = ::FastHaml::AttributeBuilder.new(#{options.to_hash.inspect})"],
         *attrs.map { |attr| compile(attr) },
           [:dynamic, "#{@sym}.build"],
        ]
      end
    end

    def on_html_attr(name, value)
      if empty_exp?(value)
        [:static, " #{name}"]
      else
        [:multi,
         [:static, " #{name}=#{options[:attr_quote]}"],
        compile(value),
          [:static, options[:attr_quote]]]
      end
    end

    def on_haml_attr(code)
      [:code, "#{@sym}.merge!(#{code})"]
    end
  end
end
