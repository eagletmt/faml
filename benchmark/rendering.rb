#!/usr/bin/env ruby
require 'benchmark/ips'
require 'haml'
require 'faml'
require 'escape_utils/html/haml'

template = ARGV[0]
unless template
  $stderr.puts "Usage: #{$0} template.haml"
  exit 1
end

Benchmark.ips do |x|
  obj = Object.new

  Haml::Engine.new(File.read(template), ugly: true, escape_html: true).def_method(obj, :haml)
  code_array = Faml::Engine.new.call(File.read(template))
  obj.instance_eval("def faml_array; #{code_array}; end")
  code_string = Faml::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(File.read(template))
  obj.instance_eval("def faml_string; #{code_string}; end")

  x.report('Haml') do
    obj.haml
  end

  x.report('Faml (Array)') do
    obj.faml_array
  end

  x.report('Faml (String)') do
    obj.faml_string
  end

  x.compare!
end
