# frozen_string_literal: true
require_relative '../faml'
require 'thor'

module Faml
  class CLI < Thor
    package_name 'faml'

    desc 'render FILE', 'Render haml template'
    option :format, type: :string, default: :html, desc: 'HTML format'
    option :extend_helpers, type: :boolean, default: false, desc: 'Extend Faml::Helpers or not'
    def render(file)
      code = compile_file(file, format: options[:format].to_sym, extend_helpers: options[:extend_helpers])
      puts instance_eval(code, file)
    end

    desc 'compile FILE', 'Compile haml template'
    option :format, type: :string, default: :html, desc: 'HTML format'
    option :extend_helpers, type: :boolean, default: false, desc: 'Extend Faml::Helpers or not'
    def compile(file)
      puts compile_file(file, format: options[:format].to_sym, extend_helpers: options[:extend_helpers])
    end

    desc 'temple FILE', 'Render temple AST'
    option :format, type: :string, default: :html, desc: 'HTML format'
    option :extend_helpers, type: :boolean, default: false, desc: 'Extend Faml::Helpers or not'
    def temple(file)
      require 'pp'
      pp Faml::Compiler.new(filename: file, format: options[:format].to_sym, extend_helpers: options[:extend_helpers]).call(parse_file(file))
    end

    desc 'stats FILE/DIR ...', 'Show statistics'
    def stats(*paths)
      require_relative 'stats'
      Stats.new(*paths).report
    end

    desc 'version', 'Print version'
    option :numeric, type: :boolean, default: false, desc: 'Print version number only'
    def version
      if options[:numeric]
        puts VERSION
      else
        puts "faml #{VERSION}"
      end
    end

    private

    def compile_file(file, opts)
      Faml::Engine.new(opts.merge(filename: file)).call(File.read(file))
    end

    def parse_file(file)
      HamlParser::Parser.new(filename: file).call(File.read(file))
    end
  end
end
