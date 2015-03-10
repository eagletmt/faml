#!/usr/bin/env ruby
require 'benchmark/ips'
require 'haml'
require 'fast_haml'
require 'escape_utils/html/haml'

template = ARGV[0]
unless template
  $stderr.puts "Usage: #{$0} template.haml"
  exit 1
end

Benchmark.ips do |x|
  obj = Object.new

  Haml::Engine.new(File.read(template), ugly: true, escape_html: true).def_method(obj, :haml)
  code_array = FastHaml::Engine.new.call(File.read(template))
  obj.instance_eval("def fast_haml_array; #{code_array}; end")
  code_string = FastHaml::Engine.new(generator: Temple::Generators::RailsOutputBuffer).call(File.read(template))
  obj.instance_eval("def fast_haml_string; #{code_string}; end")

  x.report('Haml') do
    obj.haml
  end

  x.report('FastHaml (Array)') do
    obj.fast_haml_array
  end

  x.report('FastHaml (String)') do
    obj.fast_haml_string
  end

  x.compare!
end
