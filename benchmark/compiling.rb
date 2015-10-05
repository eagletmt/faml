#!/usr/bin/env ruby
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
  x.report('Haml') { Haml::Engine.new(haml_code, ugly: true, escape_html: true) }
  x.report('Faml') { Faml::Engine.new.call(haml_code) }
  x.report('Hamlit') { Hamlit::Engine.new.call(haml_code) }
  if slim_code
    x.report('Slim') { Slim::Engine.new.call(slim_code) }
  end
  x.compare!
end
