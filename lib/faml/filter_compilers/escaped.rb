# frozen-string-literal: true
require_relative 'base'

module Faml
  module FilterCompilers
    class Escaped < Base
      include Temple::Utils

      def compile(ast)
        temple = [:multi, [:newline]]
        compile_texts(temple, ast.lineno, ast.texts)
        temple << [:static, "\n"]
        escape_code = Temple::Filters::Escapable.new(use_html_safe: false).instance_variable_get(:@escape_code)
        sym = unique_name
        [:multi,
         [:capture, sym, temple],
         [:dynamic, escape_code % sym],
        ]
      end
    end

    register(:escaped, Escaped)
  end
end
