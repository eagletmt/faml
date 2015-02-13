require 'fast_haml/attribute_builder'

module FastHaml
  class Html < Temple::HTML::Fast
    def on_html_tag(name, self_closing, attrs, content = nil)
      name = name.to_s
      closed = self_closing && (!content || empty_exp?(content))
      result = [:multi, [:static, "<#{name}"], compile(attrs)]
      result << [:static, (closed && @format != :html ? ' /' : '') + '>']
      result << compile(content) if content
      result << [:static, "</#{name}>"] if !closed
      result
    end

    def on_haml_attrs(code)
      [:dynamic, "::FastHaml::AttributeBuilder.build(#{options[:attr_quote].inspect}, #{code})"]
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

    def on_html_doctype(type)
      super
    rescue Temple::FilterError
      [:multi]
    end
  end
end
