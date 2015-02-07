module FastHaml
  module FilterCompilers
    class Javascript
      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        texts.each do |text|
          temple << [:static, '  '] << [:static, text] << [:static, "\n"]
        end
        [:html, :tag, 'script', [:html, :attrs], [:html, :js, temple]]
      end
    end

    register(:javascript, Javascript)
  end
end
