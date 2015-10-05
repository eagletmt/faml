require 'minitest/autorun'
require 'json'
require 'faml'

class HamlTest < Minitest::Test
  contexts = JSON.parse(File.read(File.join(__dir__, 'haml-spec', 'tests.json')))
  contexts.each do |context|
    context[1].each do |name, test|
      define_method("test_spec: #{name} (#{context[0]})") do
        html             = test['html']
        haml             = test['haml']
        locals           = Hash[(test['locals'] || {}).map { |x, y| [x.to_sym, y] }]
        options          = Hash[(test['config'] || {}).map { |x, y| [x.to_sym, y] }]
        options[:format] = options[:format].to_sym if options.key?(:format)
        tilt = Tilt.new("#{name}.haml", nil, options) { haml }
        result = tilt.render(Object.new, locals)

        assert_equal html, result.strip
      end
    end
  end
end
