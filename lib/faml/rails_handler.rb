# frozen_string_literal: true
module Faml
  class RailsHandler
    def call(template, source = nil)
      source ||= template.source
      Engine.new(
        use_html_safe: true,
        generator: Temple::Generators::RailsOutputBuffer,
        filename: template.identifier,
      ).call(source)
    end
  end
end
