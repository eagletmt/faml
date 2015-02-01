module FastHaml
  module Ast
    module Construct
    end

    module HasChildren
      def initialize(*)
        super
        self.children ||= []
      end

      def <<(ast)
        self.children << ast
      end

      def concat(ast)
        self.children.concat(ast)
      end
    end

    class Root < Struct.new(:children)
      include HasChildren
    end

    class Doctype < Struct.new(:doctype)
    end

    class Element < Struct.new(:children, :tag_name, :static_class, :static_id, :old_attributes, :new_attributes, :oneline_child)
      include HasChildren

      def initialize(*)
        super
        self.static_class ||= ''
        self.static_id ||= ''
        self.old_attributes ||= ''
        self.new_attributes ||= ''
      end
    end

    class Script < Struct.new(:children, :script)
      include HasChildren
    end

    class SilentScript < Struct.new(:children, :script)
      include HasChildren
    end

    class HtmlComment < Struct.new(:comment)
    end

    class Text < Struct.new(:text)
    end
  end
end
