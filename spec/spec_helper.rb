# frozen_string_literal: true
require 'simplecov'
require 'coveralls'

SimpleCov.formatters = [
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

  def with_each_attribute_type(key, val, tag: 'span', text: '', klass: nil, id: nil)
    if id
      tag = "#{tag}##{id}"
    end
    if klass
      tag = "#{tag}.#{klass}"
    end
    aggregate_failures do
      yield("%#{tag}{#{key}: #{val}}#{text}")
      yield("- v = #{val}\n%#{tag}{#{key}: v}#{text}")
      yield("- h = {#{key}: #{val}}\n%#{tag}{h}#{text}")
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

  config.before(:suite) do
    @records = Hash.new { |h, k| h[k] = Set.new }
    @trace = TracePoint.new(:call) do |tp|
      meth =
        begin
          tp.defined_class.instance_method(tp.method_id)
        rescue NameError => e
          puts "Cannot get method: #{e}: #{tp.inspect}"
          nil
        end
      if meth
        tp.defined_class.instance_method(tp.method_id).parameters.each do |_, arg_name|
          signature = "#{tp.defined_class}##{tp.method_id}(#{arg_name})"
          if arg_name && signature.start_with?('Faml::')
            @records[signature].add(tp.binding.local_variable_get(arg_name).class)
          end
        end
      end
    end
    @trace.enable
  end

  config.after(:suite) do
    @trace.disable
    @records.each do |sig, types|
      case
      when types.size == 1
        puts "#{sig} has type #{types.first}"
      when types.size == 2 && types.member?(NilClass)
        puts "#{sig} has type #{types.find { |t| t != NilClass }} (nullable)"
      when types.size == 2 && types.member?(TrueClass) && types.member?(FalseClass)
        puts "#{sig} has type boolean"
      else
        puts "#{sig} has these types: #{types.to_a}"
      end
    end
  end
end
