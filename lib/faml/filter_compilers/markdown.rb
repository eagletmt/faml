require_relative 'tilt_base'

module Faml
  module FilterCompilers
    class Markdown < TiltBase
      def need_newline?
        false
      end

      def compile(ast)
        temple = [:multi, [:newline]]
        compile_with_tilt(temple, 'markdown', ast)
        temple << [:static, "\n"]
      end
    end

    register(:markdown, Markdown)
  end
end
