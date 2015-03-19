require 'tilt'
require 'faml/engine'

module Faml
  class Tilt < Tilt::Template
    def prepare
      @code = Engine.new(options).call(data)
    end

    def precompiled_template(locals = {})
      @code
    end
  end

  ::Tilt.register(Tilt, 'haml')
  ::Tilt.register(Tilt, 'faml')
end
