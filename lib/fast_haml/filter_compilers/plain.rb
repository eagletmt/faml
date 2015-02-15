require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Plain < Base
      def compile(texts)
        temple = [:multi]
        texts = strip_last_empty_lines(texts)
        compile_texts(temple, texts[0 .. -2])
        temple << text_compiler.compile(texts[-1])
        temple
      end
    end

    register(:plain, Plain)
  end
end
