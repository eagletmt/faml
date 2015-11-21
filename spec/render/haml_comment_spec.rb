# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Haml comment rendering', type: :render do
  it 'renders nothing' do
    expect(render_string(<<HAML)).to eq("<div>\n<p>hello</p>\n<p>world</p>\n</div>\n")
%div
  %p hello
  -# this
      should
    not
      be rendered
  %p world
HAML
  end

  it 'parses empty comment' do
    expect(render_string(<<HAML)).to eq("<div>\n<p>hello</p>\n<p>world</p>\n</div>\n")
%div
  %p hello
  -#
  %p world
HAML
  end
end
