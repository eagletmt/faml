require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Plain
      def initialize
        @text_compiler = TextCompiler.new(escape_html: false)
      end

      def compile(texts)
        temple = [:multi]
        texts.each do |text|
          temple << @text_compiler.compile(text) << [:static, "\n"]
        end
        temple
      end
    end

    register(:plain, Plain)
  end
end
