require 'faml/filter_compilers/base'

module Faml
  module FilterCompilers
    class Preserve < Base
      include Temple::Utils

      def compile(texts)
        temple = [:multi, [:newline]]
        # I don't know why only :preserve filter keeps the last empty lines.
        compile_texts(temple, texts, keep_last_empty_lines: true)
        sym = unique_name
        [:multi,
          [:capture, sym, temple],
          [:dynamic, "::Faml::FilterCompilers::Preserve.preserve(#{sym})"],
        ]
      end

      def self.preserve(str)
        str.gsub("\n", '&#x000A;')
      end
    end

    register(:preserve, Preserve)
  end
end
