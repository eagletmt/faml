require 'fast_haml'
require 'thor'

module FastHaml
  class CLI < Thor
    desc 'render FILE', 'Render haml template'
    def render(file)
      puts eval(compile_file(file))
    end

    desc 'compile FILE', 'Compile haml template'
    def compile(file)
      puts compile_file(file)
    end

    desc 'parse FILE', 'Render temple AST'
    def parse(file)
      require 'pp'
      pp parse_file(file)
    end

    private

    def compile_file(file)
      FastHaml::Engine.new.call(File.read(file))
    end

    def parse_file(file)
      FastHaml::Parser.new.call(File.read(file))
    end
  end
end
