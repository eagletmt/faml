require_relative 'error'

module Faml
  module FilterCompilers
    class NotFound < Error
      def initialize(name)
        super("Unable to find compiler for #{name}", nil)
        @name = name
      end
    end

    def self.compilers
      @compilers ||= {}
    end

    def self.register(name, compiler)
      compilers[name.to_s] = compiler
    end

    def self.find(name)
      name = name.to_s
      if compilers.key?(name.to_s)
        compilers[name].new
      else
        raise NotFound.new(name)
      end
    end
  end
end

require_relative 'filter_compilers/cdata'
require_relative 'filter_compilers/coffee'
require_relative 'filter_compilers/css'
require_relative 'filter_compilers/escaped'
require_relative 'filter_compilers/javascript'
require_relative 'filter_compilers/markdown'
require_relative 'filter_compilers/plain'
require_relative 'filter_compilers/preserve'
require_relative 'filter_compilers/ruby'
require_relative 'filter_compilers/sass'
require_relative 'filter_compilers/scss'
