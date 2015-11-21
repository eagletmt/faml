# frozen-string-literal: true
module Faml
  class Railtie < ::Rails::Railtie
    initializer :faml do
      require_relative 'rails_handler'
      ActionView::Template.register_template_handler(:haml, Faml::RailsHandler.new)
      ActionView::Template.register_template_handler(:faml, Faml::RailsHandler.new)
    end
  end
end
