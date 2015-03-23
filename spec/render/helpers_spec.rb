require 'spec_helper'

RSpec.describe Faml::Helpers, type: :render do
  it 'has preserve method' do
    expect(render_string('%span!= preserve "hello\nworld !"')).to eq("<span>hello&#x000A;world !</span>\n")
  end
end
