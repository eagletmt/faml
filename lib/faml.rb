require_relative 'faml/engine'
require_relative 'faml/tilt'
require_relative 'faml/version'

begin
  gem 'rails'
  require 'rails'
  require_relative 'faml/railtie'
rescue LoadError
end
