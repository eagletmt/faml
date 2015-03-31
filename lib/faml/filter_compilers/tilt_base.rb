require 'temple'
require 'tilt'
require 'faml/filter_compilers/base'
require 'faml/text_compiler'

module Faml
  module FilterCompilers
    class TiltBase < Base
      include Temple::Utils

      def self.render_with_tilt(name, source)
        ::Tilt["t.#{name}"].new { source }.render
      end

      protected

      def compile_with_tilt(temple, name, ast)
        source = ast.texts.join("\n")
        if TextCompiler.contains_interpolation?(source)
          text_temple = [:multi]
          compile_texts(text_temple, ast.lineno, ast.texts)
          sym = unique_name
          temple << [:capture, sym, text_temple]
          temple << [:dynamic, "::Faml::FilterCompilers::TiltBase.render_with_tilt(#{name.inspect}, #{sym})"]
        else
          compiled = self.class.render_with_tilt(name, source)
          temple << [:static, compiled]
          temple.concat([[:newline]] * (ast.texts.size - 1))
        end
        temple
      end
    end
  end
end
