require 'strscan'
require 'faml/ast'
require 'faml/parser_utils'
require 'faml/ruby_multiline'
require 'faml/script_parser'
require 'faml/syntax_error'

module Faml
  class ElementParser
    def initialize(line_parser)
      @line_parser = line_parser
    end

    ELEMENT_REGEXP = /\A%([-:\w]+)([-:\w.#]*)(.+)?\z/o

    def parse(text)
      m = text.match(ELEMENT_REGEXP)
      unless m
        syntax_error!('Invalid element declaration')
      end

      element = Ast::Element.new
      element.filename = @line_parser.filename
      element.lineno = @line_parser.lineno
      element.tag_name = m[1]
      element.static_class, element.static_id = parse_class_and_id(m[2])
      rest = m[3] || ''

      element.attributes, rest = parse_attributes(rest)
      element.nuke_inner_whitespace, element.nuke_outer_whitespace, rest = parse_nuke_whitespace(rest)
      element.self_closing, rest = parse_self_closing(rest)
      element.oneline_child = ScriptParser.new(@line_parser).parse(rest)

      element
    end

    private

    def parse_class_and_id(class_and_id)
      classes = []
      id = ''
      scanner = StringScanner.new(class_and_id)
      until scanner.eos?
        unless scanner.scan(/([#.])([-:_a-zA-Z0-9]+)/)
          syntax_error!('Illegal element: classes and ids must have values.')
        end
        case scanner[1]
        when '.'
          classes << scanner[2]
        when '#'
          id = scanner[2]
        end
      end

      [classes.join(' '), id]
    end

    OLD_ATTRIBUTE_BEGIN = '{'
    NEW_ATTRIBUTE_BEGIN = '('

    def parse_attributes(rest)
      old_attributes = ''
      new_attributes = ''

      loop do
        case rest[0]
        when OLD_ATTRIBUTE_BEGIN
          unless old_attributes.empty?
            break
          end
          old_attributes, rest = parse_old_attributes(rest)
        when NEW_ATTRIBUTE_BEGIN
          unless new_attributes.empty?
            break
          end
          new_attributes, rest = parse_new_attributes(rest)
        else
          break
        end
      end

      attributes = old_attributes
      unless new_attributes.empty?
        if attributes.empty?
          attributes = new_attributes
        else
          attributes << ", " << new_attributes
        end
      end
      [attributes, rest]
    end

    def parse_old_attributes(text)
      text = text.dup
      s = StringScanner.new(text)
      s.pos = 1
      depth = 1
      loop do
        depth = ParserUtils.balance(s, '{', '}', depth)
        if depth == 0
          attr = s.pre_match + s.matched
          return [attr[1, attr.size-2], s.rest]
        else
          if /,\s*\z/ === text && @line_parser.has_next?
            text << "\n" << @line_parser.next_line
          else
            syntax_error!('Unmatched brace')
          end
        end
      end
    end

    def parse_new_attributes(text)
      text = text.dup
      s = StringScanner.new(text)
      s.pos = 1
      depth = 1
      loop do
        pre_pos = s.pos
        depth = ParserUtils.balance(s, '(', ')', depth)
        if depth == 0
          t = s.string.byteslice(pre_pos ... s.pos-1)
          return [parse_new_attribute_list(t), s.rest]
        else
          if @line_parser.has_next?
            text << "\n" << @line_parser.next_line
          else
            syntax_error!('Unmatched paren')
          end
        end
      end
    end

    def parse_new_attribute_list(text)
      s = StringScanner.new(text)
      attributes = []
      until s.eos?
        name = scan_key(s)
        s.skip(/\s*/)

        if scan_operator(s)
          s.skip(/\s*/)
          value = scan_value(s)
        else
          value = 'true'
        end
        spaces = s.scan(/\s*/)
        line_count = spaces.count("\n")

        attributes << "#{name.inspect} => #{value},#{"\n" * line_count}"
      end
      attributes.join
    end

    def scan_key(scanner)
      scanner.scan(/[-:\w]+/).tap do |name|
        unless name
          syntax_error!('Invalid attribute list (missing attributename)')
        end
      end
    end

    def scan_operator(scanner)
      scanner.skip(/=/)
    end

    def scan_value(scanner)
      if quote = scanner.scan(/["']/)
        scan_quoted_value(scanner, quote)
      else
        scan_variable_value(scanner)
      end
    end

    def scan_quoted_value(scanner, quote)
      re = /((?:\\.|\#(?!\{)|[^#{quote}\\#])*)(#{quote}|#\{)/
      pos = scanner.pos
      loop do
        unless scanner.scan(re)
          syntax_error!('Invalid attribute list (mismatched quotation)')
        end
        if scanner[2] == quote
          break
        end
        depth = ParserUtils.balance(scanner, '{', '}')
        if depth != 0
          syntax_error!('Invalid attribute list (mismatched interpolation)')
        end
      end
      str = scanner.string.byteslice(pos-1 .. scanner.pos-1)

      # Even if the quote is single, string interpolation is performed in Haml.
      str[0] = '"'
      str[-1] = '"'
      str
    end

    def scan_variable_value(scanner)
      scanner.scan(/(@@?|\$)?\w+/).tap do |var|
        unless var
          syntax_error!('Invalid attribute list (invalid variable name)')
        end
      end
    end

    def parse_nuke_whitespace(rest)
      m = rest.match(/\A(><|<>|[><])(.*)\z/)
      if m
        nuke_whitespace = m[1]
        [
          nuke_whitespace.include?('<'),
          nuke_whitespace.include?('>'),
          m[2],
        ]
      else
        [false, false, rest]
      end
    end

    def parse_self_closing(rest)
      if rest[0] == '/'
        if rest.size > 1
          syntax_error!("Self-closing tags can't have content")
        end
        [true, '']
      else
        [false, rest]
      end
    end

    def syntax_error!(message)
      raise SyntaxError.new(message, @line_parser.lineno)
    end
  end
end
