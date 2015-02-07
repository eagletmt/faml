module FastHaml
  class SyntaxError < StandardError
    attr_reader :lineno

    def initialize(message, lineno)
      super("#{message} at line #{lineno}")
      @lineno = lineno
    end
  end
end
