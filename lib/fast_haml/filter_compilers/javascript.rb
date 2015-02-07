require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Javascript
      def initialize
        @text_compiler = TextCompiler.new(escape_html: false)
      end

      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        texts.each do |text|
          temple << [:static, '  '] << @text_compiler.compile(text) << [:static, "\n"]
        end
        [:html, :tag, 'script', [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:javascript, Javascript)
  end
end
