# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Markdown filter rendering', type: :render do
  it 'renders Markdown filter' do
    expect(render_string(<<HAML)).to eq("<h1>hello</h1>\nworld\n")
:markdown
  # hello
world
HAML
  end

  it 'parses string interpolation' do
    expect(render_string(<<'HAML')).to eq("<h1>hello</h1>\nworld\n")
:markdown
  # #{'hello'}
world
HAML
  end
end
