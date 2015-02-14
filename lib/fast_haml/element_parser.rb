require 'strscan'
require 'fast_haml/ast'
require 'fast_haml/parser_utils'
require 'fast_haml/ruby_multiline'
require 'fast_haml/syntax_error'

module FastHaml
  class ElementParser
    def initialize(text, lineno, line_parser)
      @text = text
      @lineno = lineno
      @line_parser = line_parser
    end

    ELEMENT_REGEXP = /\A%([-:\w]+)([-:\w.#]*)(.+)?\z/o
    OLD_ATTRIBUTE_BEGIN = '{'
    NEW_ATTRIBUTE_BEGIN = '('

    def parse
      m = @text.match(ELEMENT_REGEXP)
      unless m
        syntax_error!('Invalid element declaration')
      end

      element = Ast::Element.new
      element.tag_name = m[1]
      element.static_class, element.static_id = parse_class_and_id(m[2])
      rest = m[3] || ''
      old_attributes = ''
      new_attributes = ''

      rest = rest.lstrip

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
      element.attributes = old_attributes
      unless new_attributes.empty?
        t = to_old_syntax(new_attributes)
        if element.attributes.empty?
          element.attributes = t
        else
          element.attributes << ", " << t
        end
      end

      m = rest.match(/\A(><|<>|[><])(.*)\z/)
      if m
        nuke_whitespace = m[1]
        element.nuke_inner_whitespace = nuke_whitespace.include?('<')
        element.nuke_outer_whitespace = nuke_whitespace.include?('>')
        rest = m[2]
      end

      case rest[0]
      when '='
        script = rest[1 .. -1].lstrip
        if script.empty?
          syntax_error!('No Ruby code to evaluate')
        end
        script += RubyMultiline.read(@line_parser, script)
        element.oneline_child = Ast::Script.new([], script)
      when '/'
        element.self_closing = true
        if rest.size > 1
          syntax_error!("Self-closing tags can't have content")
        end
      else
        case rest[0, 2]
        when '!=', '&='
          script = rest[2 .. -1].lstrip
          if script.empty?
            syntax_error!('No Ruby code to evaluate')
          end
          script += RubyMultiline.read(@line_parser, script)
          element.oneline_child = Ast::Script.new([], script, rest[0] == '&')
        else
          unless rest.empty?
            element.oneline_child = Ast::Text.new(rest)
          end
        end
      end

      element
    end

    private

    OLD_ATTRIBUTE_REGEX = /[{}]/o

    def parse_class_and_id(class_and_id)
      classes = []
      id = ''
      class_and_id.scan(/([#.])([-:_a-zA-Z0-9]+)/) do |type, prop|
        case type
        when '.'
          classes << prop
        when '#'
          id = prop
        end
      end

      [classes.join(' '), id]
    end

    def parse_old_attributes(text)
      text = text.dup
      s = StringScanner.new(text)
      s.pos = 1
      depth = 1
      loop do
        depth = ParserUtils.balance(s, '{', '}')
        if depth == 0
          attr = s.pre_match + s.matched
          return [attr[1, attr.size-2], s.rest.lstrip]
        else
          if text[-1] == ',' && @line_parser.has_next?
            text << @line_parser.next_line
          else
            syntax_error!('Unmatched brace')
          end
        end
      end
    end

    NEW_ATTRIBUTE_REGEX = /[\(\)]/o

    def parse_new_attributes(text)
      text = text.dup
      s = StringScanner.new(text)
      s.pos = 1
      depth = 1
      new_attributes = []
      loop do
        pre_pos = s.pos
        while depth > 0 && s.scan_until(NEW_ATTRIBUTE_REGEX)
          if s.matched == NEW_ATTRIBUTE_BEGIN
            depth += 1
          else
            depth -= 1
          end
        end
        if depth == 0
          t = s.string.byteslice(pre_pos ... s.pos-1)
          new_attributes.concat(parse_attribute_list(t))
          return [new_attributes, s.rest.lstrip]
        else
          if @line_parser.has_next?
            text << @line_parser.next_line
          else
            syntax_error!('Unmatched paren')
          end
        end
      end
    end

    def parse_attribute_list(text)
      s = StringScanner.new(text)
      list = []
      until s.eos?
        # parse key
        unless name = s.scan(/[-:\w]+/)
          syntax_error!('Invalid attribute list')
        end
        s.skip(/\s*/)

        # parse operator
        unless s.skip(/=/)
          list << [name, 'true']
          next
        end
        s.skip(/\s*/)

        # parse key
        if quote = s.scan(/["']/)
          re = /((?:\\.|\#(?!\{)|[^#{quote}\\#])*)(#{quote}|#\{)/
          pos = s.pos
          loop do
            unless s.scan(re)
              syntax_error!('Invalid attribute list')
            end
            if s[2] == quote
              break
            end
            depth = ParserUtils.balance(s, '{', '}')
            if depth != 0
              syntax_error!('Invalid attribute list')
            end
          end
          str = s.string.byteslice(pos-1 .. s.pos-1)
          # Even if the quote is single, string interpolation is performed in Haml.
          str[0] = '"'
          str[-1] = '"'
          list << [name, str]
        else
          unless var = s.scan(/(@@?|\$)?\w+/)
            syntax_error!('Invalid attribute list')
          end
          list << [name, var]
        end
        s.skip(/\s*/)
      end
      list
    end

    def to_old_syntax(new_attributes)
      new_attributes.map { |k, v| "#{k.inspect} => #{v}" }.join(', ')
    end

    def syntax_error!(message)
      raise SyntaxError.new(message, @lineno)
    end
  end
end
