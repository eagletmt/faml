module FastHaml
  class Railtie < ::Rails::Railtie
    initializer :fast_haml do |app|
      require 'fast_haml/rails_handler'
      ActionView::Template.register_template_handler(:haml, FastHaml::RailsHandler.new)
    end
  end
end
