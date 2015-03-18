require 'temple'
require 'tilt'
require 'fast_haml/filter_compilers/base'
require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class TiltBase < Base
      include Temple::Utils

      def self.render_with_tilt(name, source)
        ::Tilt["t.#{name}"].new { source }.render
      end

      protected

      def compile_with_tilt(name, texts)
        source = texts.join("\n")
        temple = [:multi, [:static, "\n"], [:newline]]
        if TextCompiler.contains_interpolation?(source)
          text_temple = [:multi]
          compile_texts(text_temple, texts)
          sym = unique_name
          temple << [:capture, sym, text_temple]
          temple << [:dynamic, "::FastHaml::FilterCompilers::TiltBase.render_with_tilt(#{name.inspect}, #{sym})"]
        else
          compiled = self.class.render_with_tilt(name, source)
          temple << [:static, compiled]
          temple.concat([[:newline]] * (texts.size - 1))
        end
        temple
      end
    end
  end
end
