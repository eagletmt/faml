require 'spec_helper'

RSpec.describe 'Multiline rendering', type: :render do
  it 'handles multiline syntax' do
    expect(render_string(<<HAML)).to eq("<p>\nfoo bar baz\nquux\n</p>\n")
%p
  = "foo " + |
    "bar " + |   
    "baz"               |
  = "quux"
HAML
  end

  it 'handles multiline with non-script line' do
    expect(render_string(<<HAML)).to eq("<p>\nfoo \nbar\n</p>\n")
%p
  foo |  
  bar
HAML
  end

  it 'handles multiline at the end of template' do
    expect(render_string(<<HAML)).to eq("<p>\nfoo  bar baz \n</p>\n")
%p
  foo  |
bar |
  baz |
HAML
  end

  it 'is not multiline' do
    expect(render_string(<<HAML)).to eq("<div>\nhello\n|\nworld\n</div>\n")
%div
  hello
  |
  world
HAML
  end

  it 'can be used in attribute list' do
    expect(render_string(<<HAML)).to eq("<div bar='2' foo='1'></div>\n")
%div{foo: 1, |
  bar: 2}
HAML
  end
end
