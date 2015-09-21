require_relative '../faml'
require 'thor'

module Faml
  class CLI < Thor
    package_name 'faml'

    desc 'render FILE', 'Render haml template'
    option :format, type: :string, default: :html, desc: 'HTML format'
    def render(file)
      code = compile_file(file, format: options[:format].to_sym)
      puts instance_eval(code, file)
    end

    desc 'compile FILE', 'Compile haml template'
    option :format, type: :string, default: :html, desc: 'HTML format'
    def compile(file)
      puts compile_file(file, format: options[:format].to_sym)
    end

    desc 'temple FILE', 'Render temple AST'
    option :format, type: :string, default: :html, desc: 'HTML format'
    def temple(file)
      require 'pp'
      pp Faml::Compiler.new(filename: file, format: options[:format].to_sym).call(parse_file(file))
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
