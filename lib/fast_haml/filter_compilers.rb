module FastHaml
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

require 'fast_haml/filter_compilers/cdata'
require 'fast_haml/filter_compilers/coffee'
require 'fast_haml/filter_compilers/css'
require 'fast_haml/filter_compilers/escaped'
require 'fast_haml/filter_compilers/javascript'
require 'fast_haml/filter_compilers/markdown'
require 'fast_haml/filter_compilers/plain'
require 'fast_haml/filter_compilers/preserve'
require 'fast_haml/filter_compilers/ruby'
require 'fast_haml/filter_compilers/sass'
require 'fast_haml/filter_compilers/scss'
