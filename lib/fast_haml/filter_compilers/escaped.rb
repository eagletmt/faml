require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Escaped < Base
      include Temple::Utils

      def compile(texts)
        temple = [:multi]
        compile_texts(temple, strip_last_empty_lines(texts))
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
