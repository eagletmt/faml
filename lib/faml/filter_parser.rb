module Faml
  class FilterParser
    def initialize(indent_tracker)
      @ast = nil
      @indent_level = nil
      @indent_tracker = indent_tracker
    end

    def enabled?
      !!@ast
    end

    def start(name, filename, lineno)
      @ast = Ast::Filter.new
      @ast.name = name
      @ast.filename
      @ast.lineno = lineno
    end

    def append(line)
      indent, text = @indent_tracker.split(line)
      if text.empty?
        @ast.texts << ''
        return
      end
      indent_level = indent.size

      if @indent_level
        if indent_level < @indent_level
          # Finish filter
          @indent_level = nil
          ast = @ast
          @ast = nil
          return ast
        end
      else
        if indent_level > @indent_tracker.current_level
          # Start filter
          @indent_level = indent_level
        else
          # Empty filter
          @ast = nil
          return nil
        end
      end

      text = line[@indent_level .. -1]
      @ast.texts << text
      nil
    end

    def finish
      @ast
    end
  end
end
