require 'spec_helper'

RSpec.describe 'Sanitize rendering', type: :render do
  it 'parses sanitized script' do
    # Default in fast_haml
    expect(render_string('&= "hello<p>unescape</p>world"')).to eq("hello&lt;p&gt;unescape&lt;/p&gt;world\n")
    expect(render_string(<<HAML)).to eq("<span>\nhello&lt;p&gt;unescape&lt;/p&gt;world\n</span>\n")
%span
  &= "hello<p>unescape</p>world"
HAML
  end

  it 'ignores single sanitize mark' do
    expect(render_string('& <p>hello</p>')).to eq("<p>hello</p>\n")
    expect(render_string('%span& <p>hello</p>')).to eq("<span><p>hello</p></span>\n")
  end
end
