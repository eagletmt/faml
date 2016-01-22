# frozen_string_literal: true
require 'faml/attribute_builder'

module Faml
  class Html < Temple::HTML::Fast
    # Override temple's default
    options[:format] = :html
    options[:attr_quote] = "'"

    def on_haml_tag(name, self_closing, attrs, content = nil)
      name = name.to_s
      closed = self_closing && (!content || empty_exp?(content))
      result = [:multi, [:static, "<#{name}"], compile(attrs)]
      result << [:static, (closed && @format != :html ? ' /' : '') + '>']
      result << compile(content) if content
      result << [:static, "</#{name}>"] unless closed
      result
    end

    def on_haml_attrs(code)
      [:dynamic, "::Faml::AttributeBuilder.build(#{options[:attr_quote].inspect}, #{options[:format] == :html}, #{code})"]
    end

    def on_haml_attr(name, value)
      if empty_exp?(value)
        true_attribute(name)
      elsif value[0] == :dvalue
        sym = unique_name
        [:multi,
         [:code, "#{sym} = (#{value[1]})"],
         [:case, sym,
          ['true', true_attribute(name)],
          ['false, nil', [:multi]],
          [:else, [:multi,
                   [:static, " #{name}=#{options[:attr_quote]}"],
                   [:escape, true, [:dynamic, sym]],
                   [:static, options[:attr_quote]],
                  ]],
         ],
        ]
      else
        [:multi,
         [:static, " #{name}=#{options[:attr_quote]}"],
         compile(value),
         [:static, options[:attr_quote]]]
      end
    end

    def on_haml_doctype(type)
      compile([:html, :doctype, type])
    rescue Temple::FilterError
      [:multi]
    end

    def on_haml_preserve(sym)
      [:dynamic, "::Faml::Compiler.find_and_preserve(#{sym}.to_s)"]
    end

    private

    def true_attribute(name)
      if @format == :html
        [:static, " #{name}"]
      else
        [:static, " #{name}=#{options[:attr_quote]}#{name}#{options[:attr_quote]}"]
      end
    end
  end
end
