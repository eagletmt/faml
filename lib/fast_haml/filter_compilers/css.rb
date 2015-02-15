require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Css < Base
      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        compile_texts(temple, strip_last_empty_lines(texts), tab_width: 2)
        [:haml, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:css, Css)
  end
end
