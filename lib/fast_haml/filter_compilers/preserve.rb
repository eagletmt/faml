require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Preserve < Base
      include Temple::Utils

      def compile(texts)
        temple = [:multi]
        texts.each do |text|
          temple << text_compiler.compile(text)
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
