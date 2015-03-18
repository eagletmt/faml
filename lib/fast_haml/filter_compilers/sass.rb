require 'fast_haml/filter_compilers/tilt_base'

module FastHaml
  module FilterCompilers
    class Sass < TiltBase
      def compile(texts)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_with_tilt(temple, 'sass', texts)
        [:haml, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:sass, Sass)
  end
end
