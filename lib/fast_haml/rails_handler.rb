module FastHaml
  class RailsHandler
    def call(template)
      Engine.new(use_html_safe: true).call(template.source)
    end
  end
end
