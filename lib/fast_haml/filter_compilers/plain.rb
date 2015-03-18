require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Plain < Base
      def compile(texts)
        temple = [:multi, [:newline]]
        texts = strip_last_empty_lines(texts)
        texts.each do |text|
          temple << text_compiler.compile(text)
          unless texts.last.equal?(text)
            temple << [:static, "\n"] << [:newline]
          end
        end
        temple
      end
    end

    register(:plain, Plain)
  end
end
