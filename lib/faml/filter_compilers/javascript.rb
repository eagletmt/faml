# frozen_string_literal: true
require_relative 'base'

module Faml
  module FilterCompilers
    class Javascript < Base
      def compile(ast)
        temple = [:multi, [:static, "\n"], [:newline]]
        compile_texts(temple, ast.lineno, ast.texts, tab_width: 2)
        temple << [:static, "\n"]
        [:haml, :tag, 'script', false, [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:javascript, Javascript)
  end
end
