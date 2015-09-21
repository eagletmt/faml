require 'haml_parser/parser'
require 'temple'
require_relative 'compiler'
require_relative 'html'
require_relative 'newline'

module Faml
  class Engine < Temple::Engine
    define_options(
      generator: Temple::Generators::ArrayBuffer,
      filename: nil,
    )

    use HamlParser::Parser
    use Compiler
    use Html
    filter :Escapable
    filter :ControlFlow
    filter :MultiFlattener
    use Newline
    filter :StaticMerger
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_key?(k) })
    end
  end
end
