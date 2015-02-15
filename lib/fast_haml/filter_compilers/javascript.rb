require 'fast_haml/filter_compilers/base'

module FastHaml
  module FilterCompilers
    class Javascript < Base
      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        compile_texts(temple, strip_last_empty_lines(texts), tab_width: 2)
        [:haml, :tag, 'script', false, [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:javascript, Javascript)
  end
end
