require 'fast_haml/text_compiler'

module FastHaml
  module FilterCompilers
    class Base
      def need_newline?
        true
      end

      protected

      def compile_texts(temple, texts, tab_width: 0, keep_last_empty_lines: false)
        tabs = ' ' * tab_width
        unless keep_last_empty_lines
          texts = strip_last_empty_lines(texts)
        end
        texts.each do |text|
          temple << [:static, tabs] << text_compiler.compile(text)
          unless texts.last.equal?(text)
            temple << [:static, "\n"] << [:newline]
          end
        end
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
