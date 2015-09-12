require 'spec_helper'

RSpec.describe 'filter rendering', type: :render do
  it 'raises error if invalid filter name is given' do
    expect { render_string(':filter with spaces') }.to raise_error(HamlParser::Error)
  end

  it 'raises error if unregistered filter name is given' do
    expect { render_string(':eagletmt') }.to raise_error(Faml::FilterCompilers::NotFound)
  end
end
