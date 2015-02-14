require 'fast_haml/ast'
require 'fast_haml/element_parser'
require 'fast_haml/filter_parser'
require 'fast_haml/indent_tracker'
require 'fast_haml/line_parser'
require 'fast_haml/parser_utils'
require 'fast_haml/ruby_multiline'
require 'fast_haml/syntax_error'

module FastHaml
  class Parser
    def initialize(options = {})
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
    end

    private


    DOCTYPE_PREFIX = '!'
    ELEMENT_PREFIX = '%'
    SCRIPT_PREFIX = '='
    COMMENT_PREFIX = '/'
    SILENT_SCRIPT_PREFIX = '-'
    DIV_ID_PREFIX = '#'
    DIV_CLASS_PREFIX = '.'
    FILTER_PREFIX = ':'
    ESCAPE_PREFIX = '\\'
    PRESERVE_PREFIX = '~'
    SANITIZE_PREFIX = '&'

    def parse_line(line)
      text, indent = @indent_tracker.process(line, @line_parser.lineno)

      if text.empty?
        return
      end

      if @ast.is_a?(Ast::HamlComment)
        @ast << Ast::Text.new(text)
        return
      end

      case text[0]
      when ESCAPE_PREFIX
        parse_plain(text[1 .. -1])
      when ELEMENT_PREFIX
        parse_element(text)
      when DOCTYPE_PREFIX
        case
        when text.start_with?('!!!')
          parse_doctype(text)
        when text[1] == SCRIPT_PREFIX
          parse_script(text)
        else
          parse_plain(text)
        end
      when COMMENT_PREFIX
        parse_comment(text)
      when SCRIPT_PREFIX
        parse_script(text)
      when SILENT_SCRIPT_PREFIX
        parse_silent_script(text)
      when PRESERVE_PREFIX
        # XXX: preserve has no meaning in "ugly" mode?
        parse_script(text)
      when DIV_ID_PREFIX, DIV_CLASS_PREFIX
        if text.start_with?('#{')
          parse_plain(text)
        else
          parse_line("#{indent}%div#{text}")
        end
      when FILTER_PREFIX
        parse_filter(text)
      when SANITIZE_PREFIX
        if text[1] == SCRIPT_PREFIX
          parse_script(text)
        else
          parse_plain(text)
        end
      else
        parse_plain(text)
      end
    end

    def parse_doctype(text)
      @ast << Ast::Doctype.new(text[3 .. -1].strip)
    end

    def parse_comment(text)
      text = text[1, text.size-1].strip
      comment = Ast::HtmlComment.new
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
      @ast << Ast::Text.new(text)
    end

    def parse_element(text)
      @ast << ElementParser.new(text, @line_parser.lineno, @line_parser).parse
    end

    def parse_script(text)
      m = text.match(/\A([!&~])?[=~] *(.*)\z/)
      script = m[2]
      if script.empty?
        syntax_error!("No Ruby code to evaluate")
      end
      script += RubyMultiline.read(@line_parser, script)
      node = Ast::Script.new([], script)
      case m[1]
      when '!'
        node.escape_html = false
      when '&'
        node.escape_html = true
      end
      @ast << node
    end

    def parse_silent_script(text)
      if text.start_with?('-#')
        @ast << Ast::HamlComment.new
        return
      end
      script = text[/\A- *(.*)\z/, 1]
      if script.empty?
        syntax_error!("No Ruby code to evaluate")
      end
      script += RubyMultiline.read(@line_parser, script)
      @ast << Ast::SilentScript.new([], script)
    end

    def parse_filter(text)
      filter_name = text[/\A#{FILTER_PREFIX}(\w+)\z/, 1]
      unless filter_name
        syntax_error!("Invalid filter name: #{text}")
      end
      @filter_parser.start(filter_name)
    end

    def indent_enter(_, text)
      @stack.push(@ast)
      @ast = @ast.children.last
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
