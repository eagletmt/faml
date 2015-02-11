require 'spec_helper'

RSpec.describe 'Script rendering', type: :render do
  it 'parses script' do
    expect(render_string('%span= 1 + 2')).to eq("<span>3</span>\n")
  end

  it 'parses preserve script' do
    expect(render_string('%span= 1 + 2')).to eq("<span>3</span>\n")
  end

  it 'parses unescape script' do
    expect(render_string('%span!= "hello<p>unescape</p>world"')).to eq("<span>hello<p>unescape</p>world</span>\n")
    expect(render_string(<<HAML)).to eq("<span>\nhello<p>unescape</p>world\n</span>\n")
%span
  != "hello<p>unescape</p>world"
HAML
    expect(render_string('%span!"hello"')).to eq(%Q|<span>!"hello"</span>\n|)
  end

  it 'parses sanitized script' do
    # Default in fast_haml
    expect(render_string('%span&= "hello<p>unescape</p>world"')).to eq("<span>hello&lt;p&gt;unescape&lt;/p&gt;world</span>\n")
    expect(render_string(<<HAML)).to eq("<span>\nhello&lt;p&gt;unescape&lt;/p&gt;world\n</span>\n")
%span
  &= "hello<p>unescape</p>world"
HAML
    expect(render_string('%span&"hello"')).to eq(%Q|<span>&"hello"</span>\n|)
  end

  it 'parses multi-line script' do
    expect(render_string(<<HAML)).to eq("<span>\n3\n</span>\n")
%span
  = 1 + 2
HAML
  end

  it 'parses script and text' do
    expect(render_string(<<HAML)).to eq("<span>\n3\n3\n9\n</span>\n")
%span
  = 1 + 2
  3
  = 4 + 5
HAML
  end

  it 'can contain Ruby comment' do
    expect(render_string('%span= 1 + 2 # comments')).to eq("<span>3</span>\n")
  end

  it 'can contain Ruby comment in multi-line' do
    expect(render_string(<<HAML)).to eq("<span>\n3\n3\n9\n</span>\n")
%span
  = 1 + 2 # comment
  3
  = 4 + 5 # comment
HAML
  end

  it 'can have children' do
    expect(render_string(<<HAML)).to eq("<span>0</span>\n1<span>end</span>\n")
= 1.times do |i|
  %span= i
%span end
HAML
  end

  it 'escapes unsafe string' do
    expect(render_string(<<HAML)).to eq("<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>\n")
- title = '<script>alert(1)</script>'
%p= title
HAML
  end

  it 'parses Ruby multiline' do
    expect(render_string(<<HAML)).to eq("<div>\n<span>\n2+3i\n</span>\n</div>\n")
%div
  %span
    = Complex(2,
3)
HAML
  end

  context 'without Ruby code' do
    it 'raises error' do
      expect { render_string('%span=') }.to raise_error(FastHaml::SyntaxError)
    end

    it 'raises error' do
      expect { render_string(<<HAML) }.to raise_error(FastHaml::SyntaxError)
%span
  =
HAML
    end
  end
end
