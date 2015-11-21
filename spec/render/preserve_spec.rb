# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Preserve rendering', type: :render do
  it 'parses preserved script' do
    expect(render_string('~ "<p>hello\nworld</p>"')).to eq("&lt;p&gt;hello\nworld&lt;/p&gt;\n")
    expect(render_string('%span~ "<p>hello\nworld</p>"')).to eq("<span>&lt;p&gt;hello\nworld&lt;/p&gt;</span>\n")
  end
end
