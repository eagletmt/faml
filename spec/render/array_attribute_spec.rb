# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Array attributes rendering', type: :render do
  describe 'class' do
    it 'renders array class' do
      expect(render_string('%span.c2{class: "c1"}')).to eq("<span class='c1 c2'></span>\n")
      expect(render_string('%span.c2{class: ["c1", "c3", :c2]}')).to eq("<span class='c1 c2 c3'></span>\n")
    end

    it 'merges classes' do
      expect(render_string(<<HAML)).to eq("<span class='c1 c2 content {}' id='main_id1_id3_id2'>hello</span>\n")
- h1 = {class: 'c1', id: ['id1', 'id3']}
- h2 = {class: [{}, 'c2'], id: 'id2'}
%span#main.content{h1, h2} hello
HAML
    end

    it 'remove duplicated classes' do
      aggregate_failures do
        expect(render_string('%span.foo{class: :foo}')).to eq("<span class='foo'></span>\n")
        expect(render_string('%span.foo{class: "foo bar"}')).to eq("<span class='bar foo'></span>\n")
        expect(render_string('%span.foo{class: %w[foo bar]}')).to eq("<span class='bar foo'></span>\n")
      end
      aggregate_failures do
        expect(render_string("- v = :foo\n%span.foo{class: v}")).to eq("<span class='foo'></span>\n")
        expect(render_string("- v = 'foo bar'\n%span.foo{class: v}")).to eq("<span class='bar foo'></span>\n")
        expect(render_string("- v = %w[foo bar]\n%span.foo{class: v}")).to eq("<span class='bar foo'></span>\n")
      end
      aggregate_failures do
        expect(render_string("- h = {class: :foo}\n%span.foo{h}")).to eq("<span class='foo'></span>\n")
        expect(render_string("- h = {class: 'foo bar'}\n%span.foo{h}")).to eq("<span class='bar foo'></span>\n")
        expect(render_string("- h = {class: %w[foo bar]}\n%span.foo{h}")).to eq("<span class='bar foo'></span>\n")
      end
    end

    it 'skips empty array class' do
      expect(render_string('%span{class: []}')).to eq("<span></span>\n")
    end

    it 'skips falsey array elements in class' do
      expect(render_string('%span{class: [1, nil, false, true]}')).to eq("<span class='1 true'></span>\n")
      expect(render_string("- v = [1, nil, false, true]\n%span{class: v}")).to eq("<span class='1 true'></span>\n")
      expect(render_string("- h = { class: [1, nil, false, true] }\n%span{h}")).to eq("<span class='1 true'></span>\n")
    end

    it 'flattens array class' do
      expect(render_string('%span{class: [1, [2]]}')).to eq("<span class='1 2'></span>\n")
      expect(render_string("- v = [1, [2]]\n%span{class: v}")).to eq("<span class='1 2'></span>\n")
      expect(render_string("- h = { class: [1, [2]] }\n%span{h}")).to eq("<span class='1 2'></span>\n")
    end

    it 'merges static class' do
      expect(render_string('.foo{class: "bar"} baz')).to eq("<div class='bar foo'>baz</div>\n")
      expect(render_string(<<'HAML')).to eq("<div class='bar foo'>baz</div>\n")
- bar = 'bar'
.foo{class: "#{bar}"} baz
HAML
    end
  end

  describe 'id' do
    it 'skips empty array id' do
      expect(render_string('%span{id: []}')).to eq("<span></span>\n")
    end

    it 'skips falsey array elements in id' do
      expect(render_string('%span{id: [1, nil, false, true]}')).to eq("<span id='1_true'></span>\n")
      expect(render_string("- v = [1, nil, false, true]\n%span{id: v}")).to eq("<span id='1_true'></span>\n")
      expect(render_string("- h = { id: [1, nil, false, true] }\n%span{h}")).to eq("<span id='1_true'></span>\n")
    end

    it 'flattens array id' do
      expect(render_string('%span{id: [1, [2]]}')).to eq("<span id='1_2'></span>\n")
      expect(render_string("- v = [1, [2]]\n%span{id: v}")).to eq("<span id='1_2'></span>\n")
      expect(render_string("- h = { id: [1, [2]] }\n%span{h}")).to eq("<span id='1_2'></span>\n")
    end

    it 'merges static id' do
      expect(render_string('#foo{id: "bar"} baz')).to eq("<div id='foo_bar'>baz</div>\n")
      expect(render_string('#foo{id: %w[bar baz]} hoge')).to eq("<div id='foo_bar_baz'>hoge</div>\n")
    end
  end
end
