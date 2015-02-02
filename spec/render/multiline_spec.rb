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
end
