require 'spec_helper'

RSpec.describe 'JavaScript filter renderiong', type: :render do
  it 'renders javascript filter' do
    expect(render_string(<<HAML)).to eq("<div>\n<script>\n  alert('hello');\n</script>\n<span>world</span>\n</div>\n")
%div
  :javascript
    alert('hello');
  %span world
HAML
  end

  it 'keeps indent' do
    expect(render_string(<<HAML)).to eq("<div>\n<script>\n  alert('hello');\n  \n      alert('world');\n</script>\n</div>\n")
%div
  :javascript
    alert('hello');

        alert('world');
HAML
  end

  it 'ignores empty filter' do
    expect(render_string(<<HAML)).to eq("<div>\n<span>world</span>\n</div>\n")
%div
  :javascript
  %span world
HAML
  end

  it 'parses string interpolation' do
    expect(render_string(<<'HAML')).to eq("<script>\n  var x = 3;\n</script>\n")
:javascript
  var x = #{1 + 2};
HAML
  end

  it "doesn't escape in string interpolation" do
    expect(render_string(<<'HAML')).to eq("<script>\n  <span/>\n</script>\n")
:javascript
  #{'<span/>'}
HAML
  end
end
