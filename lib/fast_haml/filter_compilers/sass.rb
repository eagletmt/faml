require 'fast_haml/filter_compilers/tilt_base'

module FastHaml
  module FilterCompilers
    class Sass < TiltBase
      def compile(texts)
        temple = compile_with_tilt('sass', texts)
        temple << [:static, "\n"]
        [:haml, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:sass, Sass)
  end
end
