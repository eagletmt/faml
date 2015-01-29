require 'spec_helper'

RSpec.describe FastHaml::Parser, type: :parser do
  describe 'attribute' do
    it 'parses attributes' do
      expect(render_string('%span{class: "x"} hello')).to eq('<span class="x">hello</span>')
    end

    it 'parses attributes' do
      expect(render_string('%span{class: "x", "old" => 2} hello')).to eq('<span class="x" old="2">hello</span>')
    end

    it 'renders dynamic attributes' do
      expect(render_string(%q|%span{class: "na#{'ni'}ka"} hello|)).to eq('<span class="nanika">hello</span>')
    end

    it 'escapes' do
      expect(render_string(%q|%span{class: "x\"y'z"} hello|)).to eq('<span class="x&quot;y&#39;z">hello</span>')
    end

    it 'renders only name if value is true' do
      expect(render_string(%q|%span{foo: true, bar: 1} hello|)).to eq('<span bar="1" foo>hello</span>')
    end

    it 'renders nested attributes' do
      expect(render_string(%q|%span{foo: {bar: 1+2}} hello|)).to eq('<span foo="{:bar=&gt;3}">hello</span>')
    end

    it 'renders code attributes' do
      expect(render_string(<<HAML)).to eq('<span bar="{:hoge=&gt;:fuga}" foo="1">hello</span>')
- attrs = { foo: 1, bar: { hoge: :fuga } }
%span{attrs} hello
HAML
    end

    it 'renders dstr attributes' do
      expect(render_string(<<HAML)).to eq('<span data="x{:foo=&gt;1}y">hello</span>')
- data = { foo: 1 }
%span{data: "x\#{data}y"} hello
HAML
    end

    context 'with unmatched brace' do
      it 'raises error' do
        expect { render_string('%span{foo hello') }.to raise_error(FastHaml::Parser::SyntaxError)
      end
    end

    context 'with data attributes' do
      it 'renders nested attributes' do
        expect(render_string(%q|%span{data: {foo: 1, bar: 'baz', :hoge => :fuga}} hello|)).to eq('<span data-bar="baz" data-foo="1" data-hoge="fuga">hello</span>')
      end

      it 'renders nested dynamic attributes' do
        expect(render_string(%q|%span{data: {foo: "b#{'a'}r"}} hello|)).to eq('<span data-foo="bar">hello</span>')
      end

      it 'renders nested attributes' do
        expect(render_string(%q|%span{data: {foo: 1, bar: 2+3}} hello|)).to eq('<span data-bar="5" data-foo="1">hello</span>')
      end

      it 'renders nested code attributes' do
        expect(render_string(<<HAML)).to eq('<span data-bar="2" data-foo="1">hello</span>')
- data = { foo: 1, bar: 2 }
%span{data: data} hello
HAML
      end
    end
  end
end
