# frozen-string-literal: true
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start do
  add_filter File.dirname(__FILE__)
end

require 'faml'

module RenderSpecHelper
  if ENV['GENERATE_INCOMPATIBILITIES'] == '1'
    require_relative 'support/incompatibilities_generator'

    def render_string(str, options = {})
      loc = caller_locations(1..1)[0]
      eval(Faml::Engine.new(options).call(str)).tap do |html|
        IncompatibilitiesGenerator.instance.record(str, options, html, RSpec.current_example, loc.lineno)
      end
    rescue => e
      IncompatibilitiesGenerator.instance.record(str, options, e, RSpec.current_example, loc.lineno)
      raise e
    end
  else
    def render_string(str, options = {})
      eval(Faml::Engine.new(options).call(str))
    end
  end
end

module Faml
  TestStruct = Struct.new(:id)
  TestRefStruct = Struct.new(:id) do
    def haml_object_ref
      'faml_test'
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  if ENV['TRAVIS']
    config.profile_examples = 10
  end

  config.order = :random

  Kernel.srand config.seed

  config.include(RenderSpecHelper, type: :render)

  if ENV['GENERATE_INCOMPATIBILITIES'] == '1'
    config.after :suite do
      IncompatibilitiesGenerator.instance.write_to('incompatibilities')
    end
  end
end
