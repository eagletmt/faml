require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Escaped
      include Temple::Utils

      def initialize
        @text_compiler = TextCompiler.new(escape_html: false)
      end

      def compile(texts)
        temple = [:multi]
        texts.each do |text|
          temple << @text_compiler.compile(text) << [:static, "\n"]
        end
        escape_code = Temple::Filters::Escapable.new.instance_variable_get(:@escape_code)
        sym = unique_name
        [:multi,
          [:capture, sym, temple],
          [:dynamic, escape_code % sym],
        ]
      end
    end

    register(:escaped, Escaped)
  end
end
