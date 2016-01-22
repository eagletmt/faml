# frozen_string_literal: true
module Faml
  class RailsHandler
    def call(template)
      Engine.new(
        use_html_safe: true,
        generator: Temple::Generators::RailsOutputBuffer,
        filename: template.identifier,
      ).call(template.source)
    end
  end
end
