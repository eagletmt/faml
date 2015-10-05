# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faml/version'

Gem::Specification.new do |spec|
  spec.name          = 'faml'
  spec.version       = Faml::VERSION
  spec.authors       = ['Kohei Suzuki']
  spec.email         = ['eagletmt@gmail.com']
  spec.summary       = %q{Faster implementation of Haml template language.}
  spec.description   = %q{Faster implementation of Haml template language.}
  spec.homepage      = 'https://github.com/eagletmt/faml'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0") + `git -C vendor/houdini ls-files -z`.split("\x0").map { |path| "vendor/houdini/#{path}" }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.extensions    = ['ext/attribute_builder/extconf.rb']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|incompatibilities)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'escape_utils'
  spec.add_dependency 'haml_parser', '>= 0.1.0'
  spec.add_dependency 'parser'
  spec.add_dependency 'temple', '>= 0.7.0'
  spec.add_dependency 'tilt'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coffee-script'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'haml'  # for benchmark
  spec.add_development_dependency 'hamlit', '>= 0.6.0'  # for benchmark
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rspec', '>= 3'
  spec.add_development_dependency 'sass'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'slim'  # for benchmark
end
