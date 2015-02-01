require 'spec_helper'

RSpec.describe 'Comment rendering', type: :render do
  it 'renders html comment' do
    expect(render_string('/ comments')).to eq("<!-- comments -->\n")
  end

  it 'strips spaces' do
    expect(render_string('/   comments   ')).to eq("<!-- comments -->\n")
  end
end
