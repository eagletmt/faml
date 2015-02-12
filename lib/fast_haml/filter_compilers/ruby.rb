require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Ruby < Base
      def compile(texts)
        [:multi, [:code, texts.join("\n")], [:newline]]
      end
    end

    register(:ruby, Ruby)
  end
end
