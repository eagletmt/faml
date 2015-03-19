require 'faml/filter_compilers/tilt_base'

module Faml
  module FilterCompilers
    class Coffee < TiltBase
      def compile(texts)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_with_tilt(temple, 'coffee', texts)
        temple << [:static, "\n"]
        [:haml, :tag, 'script', false, [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:coffee, Coffee)
  end
end
