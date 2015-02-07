require 'spec_helper'

RSpec.describe 'CSS filter rendering', type: :render do
  it 'renders css filter' do
    expect(render_string(<<HAML)).to eq("<div>\n<style>\n  html { font-size: 12px; }\n</style>\n<span>hello</span>\n</div>\n")
%div
  :css
    html { font-size: 12px; }
  %span hello
HAML
  end

  it 'keeps indent' do
    expect(render_string(<<HAML)).to eq("<div>\n<style>\n  html {\n    font-size: 12px;\n  }\n</style>\n<span>hello</span>\n</div>\n")
%div
  :css
    html {
      font-size: 12px;
    }
  %span hello
HAML
  end

  it 'ignores empty filter' do
    expect(render_string(<<HAML)).to eq("<div>\n<span>hello</span>\n</div>\n")
%div
  :css
  %span hello
HAML
  end

  it 'parses string interpolation' do
    expect(render_string(<<'HAML')).to eq("<style>\n  html { font-size: 12px; }\n</style>\n")
:css
  html { font-size: #{10 + 2}px; }
HAML
  end
end
