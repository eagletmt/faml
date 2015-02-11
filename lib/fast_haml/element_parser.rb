require 'strscan'
require 'fast_haml/ast'
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

      rest = rest.lstrip

      loop do
        case rest[0]
        when OLD_ATTRIBUTE_BEGIN
          unless element.old_attributes.empty?
            break
          end
          element.old_attributes, rest = parse_old_attributes(rest)
          when NEW_ATTRIBUTE_BEGIN
            unless element.new_attributes.empty?
              break
            end
            element.new_attributes, rest = parse_new_attributes(rest)
        else
          break
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
        unless rest.empty?
          element.oneline_child = Ast::Text.new(rest)
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
        while depth > 0 && s.scan_until(OLD_ATTRIBUTE_REGEX)
          if s.matched == OLD_ATTRIBUTE_BEGIN
            depth += 1
          else
            depth -= 1
          end
        end
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

    def parse_new_attributes(text)
      raise NotImplementedError.new("HTML-style attributes is not implemented yet, sorry")
    end

    def syntax_error!(message)
      raise SyntaxError.new(message, @lineno)
    end
  end
end
