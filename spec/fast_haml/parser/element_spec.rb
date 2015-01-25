require 'spec_helper'

RSpec.describe FastHaml::Parser, type: :parser do
  describe 'element' do
    it 'parses one-line element' do
      expect(render_string('%span hello')).to eq('<span>hello</span>')
    end

    it 'parses multi-line element' do
      expect(render_string(<<HAML)).to eq("<span>\nhello\n</span>")
%span
  hello
HAML
    end

    it 'parses nested elements' do
      expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\n</b>\n<i><small>world</small>\n</i>\n</span>")
%span
  %b
    hello
  %i
    %small world
HAML
    end

    it 'parses multi-line texts' do
      expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\nworld\n</b>\n</span>")
%span
  %b
    hello
    world
HAML
    end

    it 'skips empty lines' do
      expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\n</b>\n</span>")
%span

  %b

    hello

HAML
    end

    it 'parses classes' do
      expect(render_string('%span.foo.bar hello')).to eq('<span class="foo bar">hello</span>')
    end

    it 'parses id' do
      expect(render_string('%span#foo-bar hello')).to eq('<span id="foo-bar">hello</span>')
    end

    it 'parses classes and id' do
      expect(render_string('%span.foo#foo-bar.bar hello')).to eq('<span class="foo bar" id="foo-bar">hello</span>')
    end

    context 'with invalid tag name' do
      it 'raises error' do
        expect { render_string('%.foo') }.to raise_error(FastHaml::Parser::SyntaxError)
      end
    end

    it 'parses #' do
      expect(render_string('#main')).to eq('<div id="main" />')
    end

    it 'parses .' do
      expect(render_string('.wrapper.main')).to eq('<div class="wrapper main" />')
    end
  end
end
