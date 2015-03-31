require 'faml/ast'
require 'faml/element_parser'
require 'faml/error'
require 'faml/filter_parser'
require 'faml/indent_tracker'
require 'faml/line_parser'
require 'faml/parser_utils'
require 'faml/ruby_multiline'
require 'faml/script_parser'
require 'faml/syntax_error'

module Faml
  class Parser
    def initialize(options = {})
      @filename = options[:filename]
    end

    def call(template_str)
      @ast = Ast::Root.new
      @stack = []
      @line_parser = LineParser.new(template_str)
      @indent_tracker = IndentTracker.new(on_enter: method(:indent_enter), on_leave: method(:indent_leave))
      @filter_parser = FilterParser.new(@indent_tracker)

      while @line_parser.has_next?
        line = @line_parser.next_line
        if !@ast.is_a?(Ast::HamlComment) && @filter_parser.enabled?
          ast = @filter_parser.append(line)
          if ast
            @ast << ast
          end
        end
        unless @filter_parser.enabled?
          parse_line(line)
        end
      end

      ast = @filter_parser.finish
      if ast
        @ast << ast
      end
      @indent_tracker.finish
      @ast
    rescue Error => e
      if @filename && e.lineno
        e.backtrace.unshift "#{@filename}:#{e.lineno}"
      end
      raise e
    end

    private

    DOCTYPE_PREFIX = '!'
    ELEMENT_PREFIX = '%'
    COMMENT_PREFIX = '/'
    SILENT_SCRIPT_PREFIX = '-'
    DIV_ID_PREFIX = '#'
    DIV_CLASS_PREFIX = '.'
    FILTER_PREFIX = ':'
    ESCAPE_PREFIX = '\\'

    def parse_line(line)
      text, indent = @indent_tracker.process(line, @line_parser.lineno)

      if text.empty?
        @ast << Ast::Empty.new(@line_parser.lineno)
        return
      end

      if @ast.is_a?(Ast::HamlComment)
        @ast << Ast::Text.new(text).tap { |t| t.lineno = @line_parser.lineno }
        return
      end

      case text[0]
      when ESCAPE_PREFIX
        parse_plain(text[1 .. -1])
      when ELEMENT_PREFIX
        parse_element(text)
      when DOCTYPE_PREFIX
        if text.start_with?('!!!')
          parse_doctype(text)
        else
          parse_script(text)
        end
      when COMMENT_PREFIX
        parse_comment(text)
      when SILENT_SCRIPT_PREFIX
        parse_silent_script(text)
      when DIV_ID_PREFIX, DIV_CLASS_PREFIX
        if text.start_with?('#{')
          parse_script(text)
        else
          parse_line("#{indent}%div#{text}")
        end
      when FILTER_PREFIX
        parse_filter(text)
      else
        parse_script(text)
      end
    end

    def parse_doctype(text)
      @ast << Ast::Doctype.new(text[3 .. -1].strip).tap { |d| d.lineno = @line_parser.lineno }
    end

    def parse_comment(text)
      text = text[1, text.size-1].strip
      comment = Ast::HtmlComment.new
      comment.lineno = @line_parser.lineno
      comment.comment = text
      if text[0] == '['
        comment.conditional, rest = parse_conditional_comment(text)
        text.replace(rest)
      end
      @ast << comment
    end

    CONDITIONAL_COMMENT_REGEX = /[\[\]]/o

    def parse_conditional_comment(text)
      s = StringScanner.new(text[1 .. -1])
      depth = ParserUtils.balance(s, '[', ']')
      if depth == 0
        [s.pre_match, s.rest.lstrip]
      else
        syntax_error!('Unmatched brackets in conditional comment')
      end
    end

    def parse_plain(text)
      @ast << Ast::Text.new(text).tap { |t| t.lineno = @line_parser.lineno }
    end

    def parse_element(text)
      @ast << ElementParser.new(@line_parser).parse(text)
    end

    def parse_script(text)
      @ast << ScriptParser.new(@line_parser).parse(text)
    end

    def parse_silent_script(text)
      if text.start_with?('-#')
        @ast << Ast::HamlComment.new.tap { |c| c.lineno = @line_parser.lineno }
        return
      end
      node = Ast::SilentScript.new
      node.lineno = @line_parser.lineno
      node.script = text[/\A- *(.*)\z/, 1]
      if node.script.empty?
        syntax_error!("No Ruby code to evaluate")
      end
      node.script += RubyMultiline.read(@line_parser, node.script)
      @ast << node
    end

    def parse_filter(text)
      filter_name = text[/\A#{FILTER_PREFIX}(\w+)\z/, 1]
      unless filter_name
        syntax_error!("Invalid filter name: #{text}")
      end
      @filter_parser.start(filter_name, @line_parser.lineno)
    end

    def indent_enter(_, text)
      empty_lines = []
      while @ast.children.last.is_a?(Ast::Empty)
        empty_lines << @ast.children.pop
      end
      @stack.push(@ast)
      @ast = @ast.children.last
      @ast.children = empty_lines
      if @ast.is_a?(Ast::Element) && @ast.self_closing
        syntax_error!('Illegal nesting: nesting within a self-closing tag is illegal')
      end
      if @ast.is_a?(Ast::HtmlComment) && !@ast.comment.empty?
        syntax_error!('Illegal nesting: nesting within a html comment that already has content is illegal.')
      end
      if @ast.is_a?(Ast::HamlComment)
        @indent_tracker.enter_comment!
      end
      nil
    end

    def indent_leave(indent_level, text)
      parent_ast = @stack.pop
      case @ast
      when Ast::Script, Ast::SilentScript
        if indent_level == @indent_tracker.current_level
          @ast.mid_block_keyword = mid_block_keyword?(text)
        end
      end
      @ast = parent_ast
      nil
    end

    MID_BLOCK_KEYWORDS = %w[else elsif rescue ensure end when]
    START_BLOCK_KEYWORDS = %w[if begin case unless]
    # Try to parse assignments to block starters as best as possible
    START_BLOCK_KEYWORD_REGEX = /(?:\w+(?:,\s*\w+)*\s*=\s*)?(#{Regexp.union(START_BLOCK_KEYWORDS)})/
    BLOCK_KEYWORD_REGEX = /^-?\s*(?:(#{Regexp.union(MID_BLOCK_KEYWORDS)})|#{START_BLOCK_KEYWORD_REGEX.source})\b/

    def block_keyword(text)
      m = text.match(BLOCK_KEYWORD_REGEX)
      if m
        m[1] || m[2]
      else
        nil
      end
    end

    def mid_block_keyword?(text)
      MID_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    def syntax_error!(message)
      raise SyntaxError.new(message, @line_parser.lineno)
    end
  end
end
