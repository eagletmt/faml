require 'temple'
require 'fast_haml/compiler'
require 'fast_haml/generator'
require 'fast_haml/html'
require 'fast_haml/parser'

module FastHaml
  class Engine < Temple::Engine
    use Parser
    use Compiler
    use Html
    filter :Escapable
    filter :ControlFlow
    use Generator
  end
end
