require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Cdata < Base
      def compile(texts)
        temple = [:multi, [:static, "<![CDATA[\n"], [:newline]]
        compile_texts(temple, strip_last_empty_lines(texts), tab_width: 4)
        temple << [:static, "]]>"]
      end
    end

    register(:cdata, Cdata)
  end
end
