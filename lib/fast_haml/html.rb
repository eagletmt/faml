require 'fast_haml/attribute_builder'

module FastHaml
  class Html < Temple::HTML::Fast
    def initialize(*)
      super
      AttributeBuilder.instance.init(options)
    end

    def on_html_attrs(*attrs)
      if has_haml_attr?(attrs)
        [:multi,
          *attrs.map { |attr| compile(attr) },
          [:dynamic, "::FastHaml::AttributeBuilder.instance.build!"],
        ]
      else
        super
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
      [:code, "::FastHaml::AttributeBuilder.instance.merge!(#{code})"]
    end

    private

    def has_haml_attr?(attrs)
      attrs.any? do |html_attr|
        html_attr[0] == :haml && html_attr[1] == :attr
      end
    end
  end
end
