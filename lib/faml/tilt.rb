require 'tilt'
require 'tilt/haml'
require 'faml/engine'

module Faml
  class Tilt < Tilt::Template
    def prepare
      filename = nil
      if file
        filename = File.expand_path(file)
      end
      @code = Engine.new(options.merge(filename: filename)).call(data)
    end

    def precompiled_template(locals = {})
      @code
    end
  end

  ::Tilt.register(Tilt, 'haml')
  ::Tilt.register(Tilt, 'faml')
end
