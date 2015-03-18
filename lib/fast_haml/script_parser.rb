require 'fast_haml/syntax_error'

module FastHaml
  class ScriptParser
    def initialize(line_parser)
      @line_parser = line_parser
    end

    def parse(text)
      case text[0]
      when '=', '~'
        parse_script(text)
      when '&'
        parse_sanitized(text)
      when '!'
        parse_unescape(text)
      else
        parse_text(text)
      end
    end

    private

    def parse_script(text)
      if text[1] == '='
        Ast::Text.new(text[2 .. -1].strip)
      else
        script = text[1 .. -1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        script += RubyMultiline.read(@line_parser, script)
        Ast::Script.new([], script)
      end
    end

    def parse_sanitized(text)
      case
      when text.start_with?('&==')
        Ast::Text.new(text[3 .. -1].lstrip)
      when text[1] == '=' || text[1] == '~'
        script = text[2 .. -1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        script += RubyMultiline.read(@line_parser, script)
        Ast::Script.new([], script, true, text[1] == '~')
      else
        Ast::Text.new(text[1 .. -1].strip)
      end
    end

    def parse_unescape(text)
      case
      when text.start_with?('!==')
        Ast::Text.new(text[3 .. -1].lstrip, false)
      when text[1] == '=' || text[1] == '~'
        script = text[2 .. -1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        script += RubyMultiline.read(@line_parser, script)
        Ast::Script.new([], script, false, text[1] == '~')
      else
        Ast::Text.new(text[1 .. -1].lstrip, false)
      end
    end

    def parse_text(text)
      text = text.lstrip
      if text.empty?
        nil
      else
        Ast::Text.new(text)
      end
    end

    def syntax_error!(message)
      raise SyntaxError.new(message, @line_parser.lineno)
    end
  end
end
