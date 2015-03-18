require 'fast_haml/filter_compilers/tilt_base'

module FastHaml
  module FilterCompilers
    class Coffee < TiltBase
      def compile(texts)
        temple = compile_with_tilt('coffee', texts)
        [:haml, :tag, 'script', false, [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:coffee, Coffee)
  end
end
