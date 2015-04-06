module Faml
  module RubyMultiline
    def self.read(line_parser, current_text)
      buf = []
      while is_ruby_multiline?(current_text)
        current_text = line_parser.next_line
        buf << current_text
      end
      buf
    end

    # `text' is a Ruby multiline block if it:
    # - ends with a comma
    # - but not "?," which is a character literal
    #   (however, "x?," is a method call and not a literal)
    # - and not "?\," which is a character literal
    def self.is_ruby_multiline?(text)
      text && text.length > 1 && text[-1] == ?, &&
        !((text[-3, 2] =~ /\W\?/) || text[-3, 2] == "?\\")
    end
    private_class_method :is_ruby_multiline?
  end
end
