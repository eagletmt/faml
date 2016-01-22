# frozen_string_literal: true
require_relative 'tilt_base'

module Faml
  module FilterCompilers
    class Coffee < TiltBase
      def compile(ast)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_with_tilt(temple, 'coffee', ast, indent_width: 2)
        temple << [:static, "\n"]
        [:haml, :tag, 'script', false, [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:coffee, Coffee)
  end
end
