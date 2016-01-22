# frozen_string_literal: true
module Faml
  class Error < StandardError
    attr_accessor :lineno

    def initialize(message, lineno)
      super(message)
      @lineno = lineno
    end
  end

  class UnparsableRubyCode < Error
  end
end
