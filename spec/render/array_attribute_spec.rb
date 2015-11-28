# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Array attributes rendering', type: :render do
  describe 'class' do
    it 'renders array class' do
      with_each_attribute_type(:class, '"c1"', klass: 'c2') do |str|
        expect(render_string(str)).to eq("<span class='c1 c2'></span>\n")
      end
      with_each_attribute_type(:class, '["c1", "c3", :c2]', klass: 'c2') do |str|
        expect(render_string(str)).to eq("<span class='c1 c2 c3'></span>\n")
      end
    end

    it 'merges classes' do
      expect(render_string(<<HAML)).to eq("<span class='c1 c2 content {}' id='main_id1_id3_id2'>hello</span>\n")
- h1 = {class: 'c1', id: ['id1', 'id3']}
- h2 = {class: [{}, 'c2'], id: 'id2'}
%span#main.content{h1, h2} hello
HAML
    end

    it 'remove duplicated classes' do
      with_each_attribute_type(:class, ':foo', klass: 'foo') do |str|
        expect(render_string(str)).to eq("<span class='foo'></span>\n")
      end
      with_each_attribute_type(:class, '"foo bar"', klass: 'foo') do |str|
        expect(render_string(str)).to eq("<span class='bar foo'></span>\n")
      end
      with_each_attribute_type(:class, '%w[foo bar]', klass: 'foo') do |str|
        expect(render_string(str)).to eq("<span class='bar foo'></span>\n")
      end
    end

    it 'skips empty array class' do
      with_each_attribute_type(:class, '[]') do |str|
        expect(render_string(str)).to eq("<span></span>\n")
      end
    end

    it 'skips falsey array elements in class' do
      with_each_attribute_type(:class, '[1, nil, false, true]') do |str|
        expect(render_string(str)).to eq("<span class='1 true'></span>\n")
      end
    end

    it 'flattens array class' do
      with_each_attribute_type(:class, '[[1, [2]]]') do |str|
        expect(render_string(str)).to eq("<span class='1 2'></span>\n")
      end
    end

    it 'merges static class' do
      with_each_attribute_type(:class, '"bar"', tag: 'div', klass: 'foo', text: 'baz') do |str|
        expect(render_string(str)).to eq("<div class='bar foo'>baz</div>\n")
      end
    end
  end

  describe 'id' do
    it 'skips empty array id' do
      with_each_attribute_type(:id, '[]') do |str|
        expect(render_string(str)).to eq("<span></span>\n")
      end
    end

    it 'skips falsey array elements in id' do
      with_each_attribute_type(:id, '[1, nil, false, true]') do |str|
        expect(render_string(str)).to eq("<span id='1_true'></span>\n")
      end
    end

    it 'flattens array id' do
      with_each_attribute_type(:id, '[1, [2]]') do |str|
        expect(render_string(str)).to eq("<span id='1_2'></span>\n")
      end
    end

    it 'merges static id' do
      with_each_attribute_type(:id, '"bar"', tag: 'div', id: 'foo', text: 'baz') do |str|
        expect(render_string(str)).to eq("<div id='foo_bar'>baz</div>\n")
      end
    end
  end
end
