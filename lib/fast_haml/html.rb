require 'fast_haml/attribute_builder'

module FastHaml
  class Html < Temple::HTML::Fast
    def on_html_attrs(*attrs)
      @sym = unique_name
      [:multi,
       [:code, "#{@sym} = ::FastHaml::AttributeBuilder.new(#{options.to_h.inspect})"],
       *attrs.map { |attr| compile(attr) },
       [:dynamic, "#{@sym}.build"],
      ]
    end

    def on_haml_attr(code)
      [:code, "#{@sym}.merge!(#{code})"]
    end
  end
end
