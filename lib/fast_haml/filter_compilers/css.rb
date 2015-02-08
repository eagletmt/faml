require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Css
      def initialize
        @text_compiler = TextCompiler.new(escape_html: false)
      end

      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        texts.each do |text|
          temple << [:static, '  '] << @text_compiler.compile(text) << [:static, "\n"]
        end
        [:html, :tag, 'style', false, [:html, :attrs], temple]
      end
    end

    register(:css, Css)
  end
end
