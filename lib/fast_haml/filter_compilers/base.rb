require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Base
      protected

      def compile_texts(temple, texts, tab_width: 0)
        tabs = ' ' * tab_width
        texts.each do |text|
          temple << [:static, tabs] << text_compiler.compile(text) << [:static, "\n"] << [:newline]
        end
        temple.pop  # discard last [:newline]
        nil
      end

      def text_compiler
        @text_compiler ||= TextCompiler.new(escape_html: false)
      end

      def strip_last_empty_lines(texts)
        texts = texts.dup
        while texts.last && texts.last.empty?
          texts.pop
        end
        texts
      end
    end
  end
end
