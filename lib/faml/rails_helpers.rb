require 'faml/helpers'

module Faml
  # Don't use these methods!

  module RailsHelpers
    def preserve(input)
      Helpers.preserve(input).html_safe
    end
  end
end
