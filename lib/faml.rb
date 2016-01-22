# frozen_string_literal: true
require_relative 'faml/engine'
require_relative 'faml/tilt'
require_relative 'faml/version'

begin
  require 'rails'
rescue LoadError
else
  require_relative 'faml/railtie'
end
