require 'spec_helper'

RSpec.describe 'Plain filter rendering', type: :render do
  it 'renders plain filter' do
    expect(render_string(<<'HAML')).to eq("<span>\nhello\n<span>world</span>\n</span>\n")
%span
  :plain
    he#{'llo'}
  %span world
HAML
  end

  it 'strips last empty lines' do
    expect(render_string(<<'HAML')).to eq("<span>\nhello\n\nabc\n<span>world</span>\n</span>\n")
%span
  :plain
    he#{'llo'}

    abc

  %span world
HAML
  end
end
