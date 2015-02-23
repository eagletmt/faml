module FastHaml
  class Railtie < ::Rails::Railtie
    initializer :fast_haml do |app|
      require 'fast_haml/rails_handler'
      begin
        # Load Haml::Plugin earlier to overwrite template handler with fast_haml.
        require 'haml/plugin'
      rescue LoadError
      end
      ActionView::Template.register_template_handler(:haml, FastHaml::RailsHandler.new)
    end
  end
end
