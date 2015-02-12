require 'spec_helper'

RSpec.describe 'Ruby filter rendering', type: :render do
  it 'renders ruby filter' do
    expect(render_string(<<HAML)).to eq("\n3\n")
:ruby
  hash = {
    a: 3,
  }
= hash[:a]
HAML
  end
end
