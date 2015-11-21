# frozen-string-literal: true
require_relative 'base'

module Faml
  module FilterCompilers
    class Cdata < Base
      def compile(ast)
        temple = [:multi, [:static, "<![CDATA[\n"], [:newline]]
        compile_texts(temple, ast.lineno, ast.texts, tab_width: 4)
        temple << [:static, "\n]]>"]
      end
    end

    register(:cdata, Cdata)
  end
end
