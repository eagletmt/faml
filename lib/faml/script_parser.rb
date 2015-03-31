require 'faml/ast'
require 'faml/ruby_multiline'
require 'faml/syntax_error'

module Faml
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
        Ast::Text.new(text[2 .. -1].strip).tap { |t| t.lineno = @line_parser.lineno }
      else
        node = Ast::Script.new
        node.lineno = @line_parser.lineno
        node.script = text[1 .. -1].lstrip
        if node.script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        node.script += RubyMultiline.read(@line_parser, node.script)
        node
      end
    end

    def parse_sanitized(text)
      case
      when text.start_with?('&==')
        Ast::Text.new(text[3 .. -1].lstrip).tap { |t| t.lineno = @line_parser.lineno }
      when text[1] == '=' || text[1] == '~'
        node = Ast::Script.new
        node.lineno = @line_parser.lineno
        node.script = text[2 .. -1].lstrip
        if node.script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        node.script += RubyMultiline.read(@line_parser, node.script)
        node.preserve = text[1] == '~'
        node
      else
        Ast::Text.new(text[1 .. -1].strip).tap { |t| t.lineno = @line_parser.lineno }
      end
    end

    def parse_unescape(text)
      case
      when text.start_with?('!==')
        Ast::Text.new(text[3 .. -1].lstrip, false).tap { |t| t.lineno = @line_parser.lineno }
      when text[1] == '=' || text[1] == '~'
        node = Ast::Script.new
        node.lineno = @line_parser.lineno
        node.escape_html = false
        node.script = text[2 .. -1].lstrip
        if node.script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        node.script += RubyMultiline.read(@line_parser, node.script)
        node.preserve = text[1] == '~'
        node
      else
        Ast::Text.new(text[1 .. -1].lstrip, false).tap { |t| t.lineno = @line_parser.lineno }
      end
    end

    def parse_text(text)
      text = text.lstrip
      if text.empty?
        nil
      else
        Ast::Text.new(text).tap { |t| t.lineno = @line_parser.lineno }
      end
    end

    def syntax_error!(message)
      raise SyntaxError.new(message, @line_parser.lineno)
    end
  end
end
