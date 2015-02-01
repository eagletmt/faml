require 'temple'
require 'fast_haml/compiler'
require 'fast_haml/html'
require 'fast_haml/parser'

module FastHaml
  class Engine < Temple::Engine
    define_options(
      generator: Temple::Generators::ArrayBuffer,
    )

    use Parser
    use Compiler
    use Html
    filter :Escapable
    filter :ControlFlow
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_key?(k) })
    end
  end
end
