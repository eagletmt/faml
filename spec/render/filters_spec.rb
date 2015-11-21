# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'filter rendering', type: :render do
  it 'raises error if unregistered filter name is given' do
    expect { render_string(':eagletmt') }.to raise_error(Faml::FilterCompilers::NotFound)
  end
end
