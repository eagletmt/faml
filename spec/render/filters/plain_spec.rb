require 'spec_helper'

RSpec.describe 'Plain filter rendering', type: :render do
  it 'renders plain filter' do
    expect(render_string(<<HAML)).to eq("<span>\nhello\n\n<span>world</span>\n</span>\n")
%span
  :plain
    he#{'llo'}
  %span world
HAML
  end
end
