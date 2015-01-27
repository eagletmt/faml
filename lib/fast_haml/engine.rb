require 'temple'
require 'fast_haml/html'
require 'fast_haml/parser'

module FastHaml
  class Engine < Temple::Engine
    use Parser
    use Html
    filter :Escapable
    filter :ControlFlow
    generator :ArrayBuffer
  end
end
