# frozen-string-literal: true
require_relative 'base'

module Faml
  module FilterCompilers
    class Css < Base
      def compile(ast)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_texts(temple, ast.lineno, ast.texts, tab_width: 2)
        temple << [:static, "\n"]
        [:haml, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:css, Css)
  end
end
