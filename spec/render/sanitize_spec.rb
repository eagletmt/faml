require 'spec_helper'

RSpec.describe 'Sanitize rendering', type: :render do
  it 'parses sanitized script' do
    # Default in faml
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

  it 'parses == syntax' do
    expect(render_string('&== =<p>hello</p>')).to eq("=<p>hello</p>\n")
    expect(render_string('%span&== =<p>hello</p>')).to eq("<span>=<p>hello</p></span>\n")
  end

  context 'with preserve' do
    it 'ignores preserve mark' do
      expect(render_string('&~ "<p>hello</p>"')).to eq("&lt;p&gt;hello&lt;/p&gt;\n")
      expect(render_string('%span&~ "<p>hello</p>"')).to eq("<span>&lt;p&gt;hello&lt;/p&gt;</span>\n")
    end
  end

  context 'without Ruby code' do
    it 'raises error' do
      expect { render_string('%span&=') }.to raise_error(HamlParser::Error)
      expect { render_string('&=') }.to raise_error(HamlParser::Error)
    end
  end
end
