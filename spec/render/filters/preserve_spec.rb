# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Preserve filter rendering', type: :render do
  it 'renders preserve filter' do
    expect(render_string(<<'HAML')).to eq("<span>start</span>\nhello&#x000A;  <p>wor&#x000A;ld</p>&#x000A;<span>hello</span>\n<span>end</span>\n")
%span start
:preserve
  hello
    #{"<p>wor\nld</p>"}
  <span>hello</span>
%span end
HAML
  end

  it 'preserves last empty lines' do
    expect(render_string(<<HAML)).to eq("hello&#x000A;&#x000A;\n<p></p>\n")
:preserve
  hello


%p
HAML
  end
end
