require 'faml/filter_compilers/base'

module Faml
  module FilterCompilers
    class Plain < Base
      def compile(texts)
        temple = [:multi, [:newline]]
        compile_texts(temple, texts)
        temple
      end
    end

    register(:plain, Plain)
  end
end
