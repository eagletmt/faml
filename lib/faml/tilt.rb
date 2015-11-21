# frozen-string-literal: true
require 'tilt'
# Load tilt/haml only when haml is available
begin
  require 'haml'
rescue LoadError
else
  require 'tilt/haml'
end
require_relative 'engine'

module Faml
  class Tilt < Tilt::Template
    def prepare
      filename = nil
      if file
        filename = File.expand_path(file)
      end
      @code = Engine.new(options.merge(filename: filename)).call(data)
    end

    def precompiled_template(_locals = {})
      @code
    end
  end

  ::Tilt.register(Tilt, 'haml')
  ::Tilt.register(Tilt, 'faml')
end
