# frozen-string-literal: true
require 'ripper'

module Faml
  class RubySyntaxChecker < Ripper
    class Error < StandardError
    end

    private

    def on_parse_error(*)
      raise Error
    end
  end
end
