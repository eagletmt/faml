require 'faml/filter_compilers/tilt_base'

module Faml
  module FilterCompilers
    class Scss < TiltBase
      def compile(ast)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_with_tilt(temple, 'scss', ast)
        temple << [:static, "\n"]
        [:haml, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:scss, Scss)
  end
end
