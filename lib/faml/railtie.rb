module Faml
  class Railtie < ::Rails::Railtie
    initializer :faml do |app|
      require 'faml/rails_handler'
      ActionView::Template.register_template_handler(:haml, Faml::RailsHandler.new)
      ActionView::Template.register_template_handler(:faml, Faml::RailsHandler.new)
    end
  end
end
