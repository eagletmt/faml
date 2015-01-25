require 'spec_helper'

RSpec.describe FastHaml::Parser, type: :parser do
  describe 'script' do
    it 'parses script' do
      expect(render_string('%span= 1 + 2')).to eq('<span>3</span>')
    end

    it 'parses multi-line script' do
      expect(render_string(<<HAML)).to eq("<span>\n3\n</span>")
%span
  = 1 + 2
HAML
    end

    it 'parses script and text' do
      expect(render_string(<<HAML)).to eq("<span>\n3\n3\n9\n</span>")
%span
  = 1 + 2
  3
  = 4 + 5
HAML
    end

    context 'without Ruby code' do
      it 'raises error' do
        expect { render_string('%span=') }.to raise_error(FastHaml::Parser::SyntaxError)
      end

      it 'raises error' do
        expect { render_string(<<HAML) }.to raise_error(FastHaml::Parser::SyntaxError)
%span
  =
HAML
      end
    end
  end
end
