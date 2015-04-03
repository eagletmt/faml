require 'faml'
require 'thor'

module Faml
  class CLI < Thor
    desc 'render FILE', 'Render haml template'
    def render(file)
      code = compile_file(file)
      puts instance_eval(code, file)
    end

    desc 'compile FILE', 'Compile haml template'
    def compile(file)
      puts compile_file(file)
    end

    desc 'parse FILE', 'Render faml AST'
    def parse(file)
      require 'pp'
      pp parse_file(file)
    end

    desc 'temple FILE', 'Render temple AST'
    def temple(file)
      require 'pp'
      pp Faml::Compiler.new(filename: file).call(parse_file(file))
    end

    private

    def compile_file(file)
      Faml::Engine.new(filename: file).call(File.read(file))
    end

    def parse_file(file)
      Faml::Parser.new(filename: file).call(File.read(file))
    end
  end
end
