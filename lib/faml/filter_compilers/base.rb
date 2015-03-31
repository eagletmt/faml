require 'faml/text_compiler'

module Faml
  module FilterCompilers
    class Base
      def need_newline?
        true
      end

      protected

      def compile_texts(temple, lineno, texts, tab_width: 0, keep_last_empty_lines: false)
        tabs = ' ' * tab_width
        n = 0
        unless keep_last_empty_lines
          texts, n = strip_last_empty_lines(texts)
        end
        texts.each_with_index do |text, i|
          temple << [:static, tabs] << text_compiler.compile(text, lineno + i + 1)
          unless texts.last.equal?(text)
            temple << [:static, "\n"] << [:newline]
          end
        end
        temple.concat([[:newline]] * n)
        nil
      end

      def text_compiler
        @text_compiler ||= TextCompiler.new(escape_html: false)
      end

      def strip_last_empty_lines(texts)
        n = 0
        texts = texts.dup
        while texts.last && texts.last.empty?
          n += 1
          texts.pop
        end
        [texts, n]
      end
    end
  end
end
