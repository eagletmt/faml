module Faml
  module FilterCompilers
    class NotFound < StandardError
      attr_reader

      def initialize(name)
        super("Unable to find compiler for #{name}")
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
      if compilers.has_key?(name.to_s)
        compilers[name].new
      else
        raise NotFound.new(name)
      end
    end
  end
end

require 'faml/filter_compilers/cdata'
require 'faml/filter_compilers/coffee'
require 'faml/filter_compilers/css'
require 'faml/filter_compilers/escaped'
require 'faml/filter_compilers/javascript'
require 'faml/filter_compilers/markdown'
require 'faml/filter_compilers/plain'
require 'faml/filter_compilers/preserve'
require 'faml/filter_compilers/ruby'
require 'faml/filter_compilers/sass'
require 'faml/filter_compilers/scss'
