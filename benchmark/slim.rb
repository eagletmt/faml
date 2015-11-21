#!/usr/bin/env ruby
# frozen-string-literal: true
require 'benchmark/ips'
require 'haml'
require 'faml'
require 'hamlit'
require 'slim'
require 'escape_utils/html/haml'

require_relative 'context'

haml_code = File.read(File.join(__dir__, 'view.haml'))
slim_code = File.read(File.join(__dir__, 'view.slim'))

context = Context.new
Haml::Engine.new(haml_code, ugly: true, escape_html: true).def_method(context, :haml)
context.instance_eval "
  def faml; #{Faml::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(haml_code)}; end
  def hamlit; #{Hamlit::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(haml_code)}; end
  def slim; #{Slim::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(slim_code)}; end
"

Benchmark.ips do |x|
  x.report('Haml') { context.haml }
  x.report('Faml') { context.faml }
  x.report('Hamlit') { context.hamlit }
  x.report('Slim') { context.slim }
  x.compare!
end
