# frozen-string-literal: true
require 'spec_helper'

RSpec.describe Faml::Helpers, type: :render do
  it 'has preserve method' do
    expect(render_string('%span!= preserve "hello\nworld !"', extend_helpers: true)).to eq("<span>hello&#x000A;world !</span>\n")
  end
end
