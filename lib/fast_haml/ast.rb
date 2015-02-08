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

    class Element < Struct.new(:children, :tag_name, :static_class, :static_id, :old_attributes, :new_attributes, :oneline_child, :self_closing)
      include HasChildren

      def initialize(*)
        super
        self.static_class ||= ''
        self.static_id ||= ''
        self.old_attributes ||= ''
        self.new_attributes ||= ''
        self.self_closing ||= false
      end
    end

    class Script < Struct.new(:children, :script, :mid_block_keyword)
      include HasChildren

      def initialize(*)
        super
        if self.mid_block_keyword.nil?
          self.mid_block_keyword = false
        end
      end
    end

    class SilentScript < Struct.new(:children, :script, :mid_block_keyword)
      include HasChildren

      def initialize(*)
        super
        if self.mid_block_keyword.nil?
          self.mid_block_keyword = false
        end
      end
    end

    class HtmlComment < Struct.new(:comment)
    end

    class HamlComment < Struct.new(:children)
      include HasChildren
    end

    class Text < Struct.new(:text)
    end

    class Filter < Struct.new(:name, :texts)
      def initialize(*)
        super
        self.texts ||= []
      end
    end
  end
end
