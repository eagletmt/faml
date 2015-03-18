require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Css < Base
      def compile(texts)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_texts(temple, texts, tab_width: 2)
        temple << [:static, "\n"]
        [:haml, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:css, Css)
  end
end
