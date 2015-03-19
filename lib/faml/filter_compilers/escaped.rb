require 'faml/filter_compilers/base'

module Faml
  module FilterCompilers
    class Escaped < Base
      include Temple::Utils

      def compile(texts)
        temple = [:multi, [:newline]]
        compile_texts(temple, texts)
        temple << [:static, "\n"]
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
