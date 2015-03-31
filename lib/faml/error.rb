module Faml
  class Error < StandardError
    attr_reader :lineno
    def initialize(message, lineno)
      super(message)
      @lineno = lineno
    end
  end
end
