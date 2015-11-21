require 'haml_parser/parser'
require 'temple'
require_relative 'compiler'
require_relative 'html'
require_relative 'newline'
require_relative 'script_end'

module Faml
  class Engine < Temple::Engine
    define_options(
      generator: Temple::Generators::ArrayBuffer,
      filename: nil,
      extend_helpers: false,
    )

    use HamlParser::Parser
    use Compiler
    use Html
    filter :Escapable
    filter :ControlFlow
    filter :MultiFlattener
    use Newline
    use ScriptEnd
    filter :StaticMerger
    use :Generator do
      options[:generator].new(options.to_hash.reject { |k, _| !options[:generator].options.valid_key?(k) })
    end
  end
end
