require 'faml/filter_compilers/base'

module Faml
  module FilterCompilers
    class Ruby < Base
      def need_newline?
        false
      end

      def compile(ast)
        [:multi, [:newline], [:code, strip_last_empty_lines(ast.texts).join("\n")]]
      end
    end

    register(:ruby, Ruby)
  end
end
