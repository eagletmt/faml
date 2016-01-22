# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'CDATA filter rendering', type: :render do
  it 'renders CDATA filter' do
    expect(render_string(<<'HAML')).to eq("<![CDATA[\n    hello\n    world\n    <span>hello</span>\n]]>\n")
:cdata
  hello
  #{'world'}
  <span>hello</span>
HAML
  end
end
