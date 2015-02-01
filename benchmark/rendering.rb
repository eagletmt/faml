#!/usr/bin/env ruby
require 'benchmark/ips'
require 'haml'
require 'fast_haml'

template = ARGV[0]
unless template
  $stderr.puts "Usage: #{$0} template.haml"
  exit 1
end

Benchmark.ips do |x|
  obj = Object.new

  Haml::Engine.new(File.read(template), ugly: true, escape_html: true).def_method(obj, :haml)
  code = FastHaml::Engine.new.call(File.read(template))
  obj.instance_eval("def fast_haml; #{code}; end")

  x.report('Haml rendering') do
    obj.haml
  end

  x.report('FastHaml rendering') do
    obj.fast_haml
  end

  x.compare!
end
