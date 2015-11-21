require 'find'
require 'pathname'
require 'haml_parser/parser'
require_relative 'static_hash_parser'

module Faml
  class Stats
    Info = Struct.new(
      :empty_attribute_count,
      :static_attribute_count,
      :static_id_or_class_attribute_count,
      :dynamic_attribute_count,
      :dynamic_attribute_with_data_count,
      :dynamic_attribute_with_newline_count,
      :ruby_attribute_count,
      :object_reference_count,
      :multi_attribute_count,
      :ast_types
    ) do
      def initialize(*)
        super
        self.ast_types ||= Hash.new { |h, k| h[k] = 0 }
        members.each do |k|
          self[k] ||= 0
        end
      end
    end

    def initialize(*paths)
      @files = find_files(paths)
    end

    def report
      info = Info.new
      @files.each do |file|
        collect_info(info, file)
      end

      report_attribute_stats(info)
      report_ast_stats(info)
    end

    private

    def find_files(paths)
      paths.flat_map do |path|
        if File.directory?(path)
          find_haml_files(path)
        else
          [path.to_s]
        end
      end
    end

    def find_haml_files(dir)
      files = []
      Find.find(dir) do |file|
        if File.extname(file) == '.haml'
          files << file
        end
      end
      files
    end

    def collect_info(info, file)
      ast = HamlParser::Parser.new(filename: file).call(File.read(file))
      walk_ast(info, ast)
    end

    def walk_ast(info, ast)
      info.ast_types[ast.class.to_s.sub(/\A.*::(.+)\z/, '\1')] += 1
      case ast
      when HamlParser::Ast::Root
        ast.children.each { |c| walk_ast(info, c) }
      when HamlParser::Ast::Doctype
        :noop
      when HamlParser::Ast::Element
        collect_attribute_info(info, ast)
        if ast.oneline_child
          walk_ast(info, ast.oneline_child)
        end
        ast.children.each { |c| walk_ast(info, c) }
      when HamlParser::Ast::Script
        ast.children.each { |c| walk_ast(info, c) }
      when HamlParser::Ast::SilentScript
        ast.children.each { |c| walk_ast(info, c) }
      when HamlParser::Ast::HtmlComment
        ast.children.each { |c| walk_ast(info, c) }
      when HamlParser::Ast::HamlComment
        ast.children.each { |c| walk_ast(info, c) }
      when HamlParser::Ast::Text
        :noop
      when HamlParser::Ast::Filter
        :noop
      when HamlParser::Ast::Empty
        :noop
      else
        raise "InternalError: Unknown ast #{ast.class}: #{ast.inspect}"
      end
    end

    def collect_attribute_info(info, ast)
      if ast.object_ref
        info.object_reference_count += 1
        return
      end

      if !ast.old_attributes && !ast.new_attributes
        if ast.static_class.empty? && ast.static_id.empty?
          info.empty_attribute_count += 1
        else
          info.static_id_or_class_attribute_count += 1
        end
      else
        static_hash_parser = StaticHashParser.new
        if static_hash_parser.parse("{#{ast.new_attributes}#{ast.old_attributes}}")
          if static_hash_parser.dynamic_attributes.empty?
            info.static_attribute_count += 1
          else
            if static_hash_parser.dynamic_attributes.key?('data') || static_hash_parser.dynamic_attributes.key?(:data)
              info.dynamic_attribute_with_data_count += 1
            elsif ast.old_attributes && ast.old_attributes.include?("\n")
              info.dynamic_attribute_with_newline_count += 1
            elsif ast.new_attributes && ast.new_attributes.include?("\n")
              info.dynamic_attribute_with_newline_count += 1
            else
              info.dynamic_attribute_count += 1
            end
          end
        else
          call_ast = Parser::CurrentRuby.parse("call(#{ast.new_attributes}#{ast.old_attributes})")
          if call_ast.type == :send && call_ast.children[0].nil? && call_ast.children[1] == :call && !call_ast.children[3].nil?
            info.multi_attribute_count += 1
          else
            info.ruby_attribute_count += 1
          end
        end
      end
    end

    def report_attribute_stats(info)
      static = info.static_attribute_count
      dynamic = info.dynamic_attribute_count + info.dynamic_attribute_with_data_count + info.dynamic_attribute_with_newline_count
      ruby = info.ruby_attribute_count + info.multi_attribute_count + info.object_reference_count
      total = static + dynamic + ruby
      puts 'Attribute stats'
      printf("  Empty attributes: %d\n", info.empty_attribute_count)
      printf("  Attributes with id or class only: %d\n", info.static_id_or_class_attribute_count)
      printf("  Static attributes: %d (%.2f%%)\n", static, static * 100.0 / total)
      printf("  Dynamic attributes: %d (%.2f%%)\n", dynamic, dynamic * 100.0 / total)
      printf("    with data: %d\n", info.dynamic_attribute_with_data_count)
      printf("    with newline: %d\n", info.dynamic_attribute_with_newline_count)
      printf("  Ruby attributes: %d (%.2f%%)\n", ruby, ruby * 100.0 / total)
      printf("    with multiple arguments: %d\n", info.multi_attribute_count)
      printf("    with object reference: %d\n", info.object_reference_count)
    end

    def report_ast_stats(info)
      total = info.ast_types.values.inject(0, :+)
      puts 'AST stats'
      info.ast_types.keys.sort.each do |type|
        v = info.ast_types[type]
        printf("  %s: %d (%.2f%%)\n", type, v, v * 100.0 / total)
      end
    end
  end
end
