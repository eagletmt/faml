require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Preserve
      include Temple::Utils

      def initialize
        @text_compiler = TextCompiler.new(escape_html: false)
      end

      def compile(texts)
        temple = [:multi]
        texts.each do |text|
          temple << @text_compiler.compile(text)
          unless texts.last.equal?(text)
            temple << [:static, "\n"]
          end
        end
        sym = unique_name
        [:multi,
          [:capture, sym, temple],
          [:dynamic, "::FastHaml::FilterCompilers::Preserve.preserve(#{sym})"],
        ]
      end

      def self.preserve(str)
        str.gsub("\n", '&#x000A;')
      end
    end

    register(:preserve, Preserve)
  end
end
