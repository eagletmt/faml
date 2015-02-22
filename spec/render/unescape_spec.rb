require 'spec_helper'

RSpec.describe 'Unescape rendering', type: :render do
  it 'parses unescape script' do
    expect(render_string('%span!= "hello<p>unescape</p>world"')).to eq("<span>hello<p>unescape</p>world</span>\n")
    expect(render_string(<<HAML)).to eq("<span>\nhello<p>unescape</p>world\n</span>\n")
%span
  != "hello<p>unescape</p>world"
HAML
  end

  it 'ignores single unescape mark' do
    expect(render_string('! <p>hello</p>')).to eq("<p>hello</p>\n")
    expect(render_string('%span! <p>hello</p>')).to eq("<span><p>hello</p></span>\n")
  end

  it 'has effect on string interpolation in plain' do
    expect(render_string('! <p>#{"<strong>hello</strong>"}</p>')).to eq("<p><strong>hello</strong></p>\n")
    expect(render_string('%span! <p>#{"<strong>hello</strong>"}</p>')).to eq("<span><p><strong>hello</strong></p></span>\n")
  end

  context 'without Ruby code' do
    it 'raises error' do
      expect { render_string('%span!=') }.to raise_error(FastHaml::SyntaxError)
      expect { render_string('!=') }.to raise_error(FastHaml::SyntaxError)
    end
  end
end
