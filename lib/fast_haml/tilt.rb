require 'tilt'
require 'fast_haml/engine'

module FastHaml
  class Tilt < Tilt::Template
    def prepare
      @code = Engine.new.call(data)
    end

    def precompiled_template(locals = {})
      @code
    end
  end

  ::Tilt.register(Tilt, 'haml')
end
