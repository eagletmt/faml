# frozen-string-literal: true
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
end
