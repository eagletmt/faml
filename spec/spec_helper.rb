require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start do
  add_filter File.dirname(__FILE__)
end

require 'fast_haml'

module RenderSpecHelper
  def render_string(str, options = {})
    eval(FastHaml::Engine.new(options).call(str))
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

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  if ENV['TRAVIS']
    config.profile_examples = 10
  end

  config.order = :random

  Kernel.srand config.seed

  config.include(RenderSpecHelper, type: :render)
end
