require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Javascript < Base
      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        compile_texts(temple, texts, tab_width: 2)
        [:html, :tag, 'script', false, [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:javascript, Javascript)
  end
end
