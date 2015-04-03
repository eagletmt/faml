module Faml
  class LineParser
    attr_reader :filename, :lineno

    def initialize(filename, template_str)
      @filename = filename
      @lines = template_str.each_line.map { |line| line.chomp.rstrip }
      @lineno = 0
    end

    def next_line
      line = move_next
      if is_multiline?(line)
        next_multiline(line)
      else
        line
      end
    end

    def has_next?
      @lineno < @lines.size
    end

    private

    MULTILINE_SUFFIX = ' |'

    # Regex to check for blocks with spaces around arguments. Not to be confused
    # with multiline script.
    # For example:
    #     foo.each do | bar |
    #       = bar
    #
    BLOCK_WITH_SPACES = /do\s*\|\s*[^\|]*\s+\|\z/o

    def is_multiline?(line)
      line = line.lstrip
      line.end_with?(MULTILINE_SUFFIX) && line !~ BLOCK_WITH_SPACES
    end

    def move_next
      @lines[@lineno].tap do
        @lineno += 1
      end
    end

    def move_back
      @lineno -= 1
    end

    def next_multiline(line)
      buf = [line[0, line.size-1]]
      while @lineno < @lines.size
        line = move_next

        if is_multiline?(line)
          line = line[0, line.size-1]
          buf << line.lstrip
        else
          move_back
          break
        end
      end
      buf.join("\n")
    end
  end
end
