module FastHaml
  module FilterCompilers
    class Css
      def compile(texts)
        temple = [:multi, [:static, "\n"]]
        texts.each do |text|
          temple << [:static, '  '] << [:static, text] << [:static, "\n"]
        end
        [:html, :tag, 'style', [:html, :attrs], temple]
      end
    end

    register(:css, Css)
  end
end
