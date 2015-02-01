require 'fast_haml/engine'
require 'fast_haml/version'

begin
  gem 'rails'
  require 'rails'
  require 'fast_haml/railtie'
rescue LoadError
end
