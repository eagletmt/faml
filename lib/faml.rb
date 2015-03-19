require 'faml/engine'
require 'faml/tilt'
require 'faml/version'

begin
  gem 'rails'
  require 'rails'
  require 'faml/railtie'
rescue LoadError
end
