require 'fast_haml/filter_compilers/tilt_base'

module FastHaml
  module FilterCompilers
    class Markdown < TiltBase
      def need_newline?
        false
      end

      def compile(texts)
        temple = [:multi, [:newline]]
        compile_with_tilt(temple, 'markdown', texts)
      end
    end

    register(:markdown, Markdown)
  end
end
