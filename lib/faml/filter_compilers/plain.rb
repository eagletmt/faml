require_relative 'base'

module Faml
  module FilterCompilers
    class Plain < Base
      def compile(ast)
        temple = [:multi, [:newline]]
        compile_texts(temple, ast.lineno, ast.texts)
        temple
      end
    end

    register(:plain, Plain)
  end
end
