require 'faml/filter_compilers/tilt_base'

module Faml
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
