require 'spec_helper'

RSpec.describe 'Escaped filter rendering', type: :render do
  it' renders escaped filter' do
    expect(render_string(<<'HAML')).to eq("<span>start</span>\nhello\n  &lt;p&gt;world&lt;/p&gt;\n&lt;span&gt;hello&lt;/span&gt;\n\n<span>end</span>\n")
%span start
:escaped
  hello
    #{'<p>world</p>'}
  <span>hello</span>
%span end
HAML
  end
end
