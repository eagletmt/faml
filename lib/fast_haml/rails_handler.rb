module FastHaml
  class RailsHandler
    def call(template)
      Engine.new.call(template.source)
    end
  end
end
