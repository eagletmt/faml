# frozen-string-literal: true
require 'temple'
require 'tilt'
require_relative 'base'

module Faml
  module FilterCompilers
    class TiltBase < Base
      include Temple::Utils

      def self.render_with_tilt(name, source, indent_width: 0)
        text = ::Tilt["t.#{name}"].new { source }.render
        indent = ' ' * indent_width
        "#{indent}#{text.rstrip.gsub("\n", "\n#{indent}")}"
      end

      protected

      def compile_with_tilt(temple, name, ast, indent_width: 0)
        source = ast.texts.join("\n")
        if TextCompiler.contains_interpolation?(source)
          text_temple = [:multi]
          compile_texts(text_temple, ast.lineno, ast.texts)
          sym = unique_name
          temple << [:capture, sym, text_temple]
          temple << [:dynamic, "::Faml::FilterCompilers::TiltBase.render_with_tilt(#{name.inspect}, #{sym}, indent_width: #{indent_width})"]
        else
          compiled = self.class.render_with_tilt(name, source, indent_width: indent_width)
          temple << [:static, compiled]
          temple.concat([[:newline]] * (ast.texts.size - 1))
        end
        temple
      end
    end
  end
end
