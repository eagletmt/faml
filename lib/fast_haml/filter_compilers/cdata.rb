require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Cdata
      def initialize
        @text_compiler = TextCompiler.new(escape_html: false)
      end

      def compile(texts)
        temple = [:multi, [:static, "<![CDATA[\n"]]
        texts.each do |text|
          temple << [:static, '    '] << @text_compiler.compile(text) << [:static, "\n"]
        end
        temple << [:static, "]]>"]
      end
    end

    register(:cdata, Cdata)
  end
end
