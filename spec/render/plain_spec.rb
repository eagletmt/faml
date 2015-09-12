require 'spec_helper'

RSpec.describe 'Plain rendering', type: :render do
  it 'outputs literally when prefixed with "\\"' do
    expect(render_string('\= @title')).to eq("= @title\n")
  end

  it 'correctly escapes interpolation' do
    expect(render_string(<<'HAML')).to eq("<span>foo\\3bar</span>\n")
%span foo\\#{1 + 2}bar
HAML
    expect(render_string(<<'HAML')).to eq("<span>foo\\\#{1 + 2}bar</span>\n")
%span foo\\\#{1 + 2}bar
HAML
  end

  it 'raises error when interpolation is unterminated' do
    expect { render_string('%span foo#{1 + 2') }.to raise_error(Faml::TextCompiler::InvalidInterpolation)
  end

  it 'raises error when text has children' do
    expect { render_string(<<HAML) }.to raise_error(HamlParser::Error, /nesting within plain text/)
hello
  world
HAML
  end
end
