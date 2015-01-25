require 'temple'
require 'fast_haml/parser'

module FastHaml
  class Engine < Temple::Engine
    use Parser
    html :AttributeSorter
    html :Fast
    filter :ControlFlow
    generator :ArrayBuffer
  end
end
