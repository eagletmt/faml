#!/usr/bin/env ruby
# frozen_string_literal: true
require 'benchmark/ips'
require 'haml'
require 'faml'
require 'hamlit'
require 'slim'
require 'escape_utils/html/haml'

unless ARGV[0]
  $stderr.puts "Usage: #{$PROGRAM_NAME} template.haml [template.slim]"
  exit 1
end

haml_code = File.read(ARGV[0])
slim_code = ARGV[1] ? File.read(ARGV[1]) : nil

Benchmark.ips do |x|
  obj = Object.new

  Haml::Engine.new(haml_code, ugly: true, escape_html: true).def_method(obj, :haml)
  obj.instance_eval "
    def faml_array; #{Faml::Engine.new.call(haml_code)}; end
    def faml_string; #{Faml::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(haml_code)}; end
    def hamlit_array; #{Hamlit::Engine.new.call(haml_code)}; end
    def hamlit_string; #{Hamlit::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(haml_code)}; end
  "
  if slim_code
    obj.instance_eval "
      def slim_array; #{Slim::Engine.new.call(slim_code)}; end
      def slim_string; #{Slim::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(slim_code)}; end
    "
  end

  x.report('Haml') { obj.haml }
  x.report('Faml (Array)') { obj.faml_array }
  x.report('Faml (String)') { obj.faml_string }
  x.report('Hamlit (Array)') { obj.hamlit_array }
  x.report('Hamlit (String)') { obj.hamlit_string }
  if slim_code
    x.report('Slim (Array)') { obj.slim_array }
    x.report('Slim (String)') { obj.slim_string }
  end
  x.compare!
end
