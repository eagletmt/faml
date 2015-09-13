require 'spec_helper'

RSpec.describe 'Script rendering', type: :render do
  it 'parses script' do
    expect(render_string('%span= 1 + 2')).to eq("<span>3</span>\n")
  end

  it 'parses multi-line script' do
    expect(render_string(<<HAML)).to eq("<span>\n3\n</span>\n")
%span
  = 1 + 2
HAML
  end

  it 'parses script and text' do
    expect(render_string(<<HAML)).to eq("<span>\n3\n3\n9\n</span>\n")
%span
  = 1 + 2
  3
  = 4 + 5
HAML
  end

  it 'can contain Ruby comment' do
    expect(render_string('%span= 1 + 2 # comments')).to eq("<span>3</span>\n")
  end

  it 'can contain Ruby comment in multi-line' do
    expect(render_string(<<HAML)).to eq("<span>\n3\n3\n9\n</span>\n")
%span
  = 1 + 2 # comment
  3
  = 4 + 5 # comment
HAML
  end

  it 'can be comment-only' do
    expect(render_string(<<HAML)).to eq("\nstring\n")
= # comment
= 'string'
HAML
  end

  it 'can have children' do
    expect(render_string(<<HAML)).to eq("<span>0</span>\n1<span>end</span>\n")
= 1.times do |i|
  %span= i
%span end
HAML
  end

  it 'escapes unsafe string' do
    expect(render_string(<<HAML)).to eq("<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>\n")
- title = '<script>alert(1)</script>'
%p= title
HAML
  end
end
