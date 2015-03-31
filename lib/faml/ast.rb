module Faml
  module Ast
    module HasChildren
      def initialize(*)
        super
        self.children ||= []
      end

      def <<(ast)
        self.children << ast
      end
    end

    class Root < Struct.new(:children)
      include HasChildren
    end

    class Doctype < Struct.new(:doctype, :filename, :lineno)
    end

    class Element < Struct.new(
      :children,
      :tag_name,
      :static_class,
      :static_id,
      :attributes,
      :oneline_child,
      :self_closing,
      :nuke_inner_whitespace,
      :nuke_outer_whitespace,
      :filename,
      :lineno,
    )
      include HasChildren

      def initialize(*)
        super
        self.static_class ||= ''
        self.static_id ||= ''
        self.attributes ||= ''
        self.self_closing ||= false
        self.nuke_inner_whitespace ||= false
        self.nuke_outer_whitespace ||= false
      end
    end

    class Script < Struct.new(
      :children,
      :script,
      :escape_html,
      :preserve,
      :mid_block_keyword,
      :filename,
      :lineno,
    )
      include HasChildren

      def initialize(*)
        super
        if self.escape_html.nil?
          self.escape_html = true
        end
        if self.preserve.nil?
          self.preserve = false
        end
        if self.mid_block_keyword.nil?
          self.mid_block_keyword = false
        end
      end
    end

    class SilentScript < Struct.new(:children, :script, :mid_block_keyword, :filename, :lineno)
      include HasChildren

      def initialize(*)
        super
        if self.mid_block_keyword.nil?
          self.mid_block_keyword = false
        end
      end
    end

    class HtmlComment < Struct.new(:children, :comment, :conditional, :filename, :lineno)
      include HasChildren

      def initialize(*)
        super
        self.comment ||= ''
        self.conditional ||= ''
      end
    end

    class HamlComment < Struct.new(:children, :filename, :lineno)
      include HasChildren
    end

    class Text < Struct.new(:text, :escape_html, :filename, :lineno)
      def initialize(*)
        super
        if self.escape_html.nil?
          self.escape_html = true
        end
      end
    end

    class Filter < Struct.new(:name, :texts, :filename, :lineno)
      def initialize(*)
        super
        self.texts ||= []
      end
    end

    class Empty < Struct.new(:filename, :lineno)
    end
  end
end
