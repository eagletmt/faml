require 'temple'
require 'fast_haml/static_hash_parser'

module FastHaml
  class Parser < Temple::Parser
    class SyntaxError < StandardError
      attr_reader :lineno

      def initialize(message, lineno)
        super("#{message} at line #{lineno}")
        @lineno = lineno
      end
    end

    def call(template_str)
      reset
      template_str.each_line.with_index do |line, lineno|
        parse_line(line.chomp, lineno)
      end
      if @indent_levels.last > 0
        indent_leave(0, '', -1)
      end
      @temple_ast
    end

    private

    def reset
      @temple_ast = [:multi]
      @stack = []
      @indent_levels = [0]
      @indent_is_silent = [false]
      @prev_silent = false
    end

    DOCTYPE_PREFIX = '!'
    ELEMENT_PREFIX = '%'
    SCRIPT_PREFIX = '='
    SILENT_SCRIPT_PREFIX = '-'
    DIV_ID_PREFIX = '#'
    DIV_CLASS_PREFIX = '.'

    def parse_line(line, lineno)
      m = line.match(/\A( *)(.*)\z/)
      indent = m[1]
      indent_level = indent.size
      text = m[2]

      if text.empty?
        return
      end

      process_indent(indent_level, text, lineno)

      case text[0]
      when ELEMENT_PREFIX
        insert_newline(@temple_ast)
        parse_element(text, lineno)
        @prev_silent = false
      when DOCTYPE_PREFIX
        insert_newline(@temple_ast)
        if text.start_with?('!!!')
          parse_doctype(text, lineno)
        else
          raise SyntaxError.new("Illegal doctype declaration", lineno)
        end
        @prev_silent = false
      when SCRIPT_PREFIX
        insert_newline(@temple_ast)
        parse_script(text, lineno)
        @prev_silent = false
      when SILENT_SCRIPT_PREFIX
        parse_silent_script(text, lineno)
        @prev_silent = true
      when DIV_ID_PREFIX, DIV_CLASS_PREFIX
        parse_line("#{indent}%div#{text}", lineno)
        @prev_silent = false
      else
        insert_newline(@temple_ast)
        parse_plain(text, lineno)
        @prev_silent = false
      end
    end

    def parse_doctype(text, lineno)
      @temple_ast << [:html, :doctype, 'html']
    end

    def parse_plain(text, lineno)
      @temple_ast << [:static, text]
    end

    OLD_ATTRIBUTE_BEGIN = '{'
    OLD_ATTRIBUTE_END = '}'

    def parse_element(text, lineno)
      m = text.match(/\A%([-:\w]+)([-:\w.#]*)(.+)?\z/)
      unless m
        raise SyntaxError.new("Invalid element declaration", lineno)
      end
      tag_name = m[1]
      attributes = m[2]
      rest = m[3]

      ast = [:html, :tag, tag_name]
      html_attrs = [:html, :attrs].concat(parse_class_and_id(attributes))
      ast << html_attrs
      if rest
        rest = rest.lstrip

        old_attributes_hash = nil
        new_attributes_hash = nil

        loop do
          case rest[0]
          when OLD_ATTRIBUTE_BEGIN
            if old_attributes_hash
              break
            end
            old_attributes_hash, rest = parse_old_attributes(rest)
          when '('
            if new_attributes_hash
              break
            end
            new_attributes_hash, rest = parse_new_attributes(rest)
          else
            break
          end
        end

        if old_attributes_hash
          html_attrs.concat(try_static_hash(old_attributes_hash))
        end

        case rest[0]
        when '='
          script = rest[1 .. -1].lstrip
          if script.empty?
            raise SyntaxError.new("No Ruby code to evaluate", lineno)
          end
          ast << [:dynamic, script]
        else
          unless rest.empty?
            ast << [:static, rest]
          end
        end
      end

      @temple_ast << ast
    end

    OLD_ATTRIBUTE_REGEX = /[{}]/o

    def parse_old_attributes(text)
      s = StringScanner.new(text)
      s.pos = 1
      depth = 1
      while depth > 0 && s.scan_until(OLD_ATTRIBUTE_REGEX)
        if s.matched == OLD_ATTRIBUTE_BEGIN
          depth += 1
        else
          depth -= 1
        end
      end
      attr = s.pre_match + s.matched
      [attr[1, attr.size-2], s.rest.lstrip]
    end

    def try_static_hash(text)
      attrs = []
      parser = StaticHashParser.new
      if parser.parse(text)
        keys = parser.static_attributes.keys + parser.dynamic_attributes.keys
        keys.sort.each do |k|
          if parser.static_attributes.has_key?(k)
            v = parser.static_attributes[k]
            if v == true
              attrs << [:html, :attr, k, [:multi]]
            else
              attrs << [:html, :attr, k, [:static, Temple::Utils.escape_html(v)]]
            end
          else
            v = parser.dynamic_attributes[k]
            attrs << [:html, :attr, k, [:escape, true, [:dynamic, v]]]
          end
        end
      else
        attrs << [:haml, :attr, text]
      end
      attrs
    end

    def parse_script(text, lineno)
      script = text[/\A= *(.*)\z/, 1]
      if script.empty?
        raise SyntaxError.new("No Ruby code to evaluate", lineno)
      end
      @temple_ast << [:dynamic, script]
    end

    def parse_silent_script(text, lineno)
      script = text[/\A- *(.*)\z/, 1]
      if script.empty?
        raise SyntaxError.new("No Ruby code to evaluate", lineno)
      end
      @temple_ast << [:code, script]
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

      ast = []
      unless classes.empty?
        ast << [:html, :attr, 'class', [:static, classes.join(' ')]]
      end
      unless id.empty?
        ast << [:html, :attr, 'id', [:static, id]]
      end
      ast
    end

    def process_indent(indent_level, text, lineno)
      if indent_level > @indent_levels.last
        indent_enter(indent_level, lineno)
      elsif indent_level < @indent_levels.last
        indent_leave(indent_level, text, lineno)
      end
    end

    def indent_enter(indent_level, lineno)
      @indent_levels.push(indent_level)
      @indent_is_silent.push(@prev_silent)
      @stack.push(@temple_ast)
      @temple_ast = [:multi]
    end

    def indent_leave(indent_level, text, lineno)
      while indent_level < @indent_levels.last
        @indent_levels.pop
        was_silent = @indent_is_silent.pop
        unless was_silent
          insert_newline(@temple_ast)
        end
        ast = @temple_ast
        @temple_ast = @stack.pop
        last_ast = @temple_ast.last

        case last_ast[0]
        when :html
          last_ast << ast
        when :code
          @temple_ast << ast
          unless mid_block_keyword?(text)
            @temple_ast << [:code, 'end']
          end
        else
          raise "Unexpected: #{last_ast}"
        end
      end
      if indent_level != @indent_levels.last
        raise SyntaxError.new("Unexpected indent level: #{indent_level}: indent_level=#{@indent_levels}", lineno)
      end
    end

    def insert_newline(ast)
      ast << [:static, "\n"]
    end
  end
end
