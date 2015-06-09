require 'faml/error'

module Faml
  class IndentTracker
    class IndentMismatch < Error
      attr_reader :current_level, :indent_levels

      def initialize(current_level, indent_levels, lineno)
        super("Unexpected indent level: #{current_level}: indent_level=#{indent_levels}", lineno)
        @current_level = current_level
        @indent_levels = indent_levels
      end
    end

    def initialize(on_enter: nil, on_leave: nil)
      @indent_levels = [0]
      @on_enter = on_enter || lambda { |level, text| }
      @on_leave = on_leave || lambda { |level, text| }
      @comment_level = nil
    end

    def process(line, lineno)
      indent, text = split(line)
      indent_level = indent.size

      unless text.empty?
        track(indent_level, text, lineno)
      end
      [text, indent]
    end

    def split(line)
      m = line.match(/\A( *)(.*)\z/)
      [m[1], m[2]]
    end

    def finish
      indent_leave(0, '', -1)
    end

    def current_level
      @indent_levels.last
    end

    def enter_comment!
      @comment_level = @indent_levels[-2]
    end

    private

    def track(indent_level, text, lineno)
      if indent_level > @indent_levels.last
        indent_enter(indent_level, text)
      elsif indent_level < @indent_levels.last
        indent_leave(indent_level, text, lineno)
      end
    end

    def indent_enter(indent_level, text)
      unless @comment_level
        @indent_levels.push(indent_level)
        @on_enter.call(indent_level, text)
      end
    end

    def indent_leave(indent_level, text, lineno)
      if @comment_level
        if indent_level <= @comment_level
          # finish comment mode
          @comment_level = nil
        else
          # still in comment
          return
        end
      end

      while indent_level < @indent_levels.last
        @indent_levels.pop
        @on_leave.call(indent_level, text)
      end

      if indent_level != @indent_levels.last
        raise IndentMismatch.new(indent_level, @indent_levels.dup, lineno)
      end
    end
  end
end
