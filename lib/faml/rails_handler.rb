module Faml
  class RailsHandler
    def call(template)
      Engine.new(
        use_html_safe: true,
        generator: Temple::Generators::RailsOutputBuffer,
      ).call(template.source)
    end
  end
end
