# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Hash attributes rendering', type: :render do
  it 'renders nested attributes' do
    expect(render_string(%q|%span{foo: {bar: 1+2}} hello|)).to eq(%Q|<span foo='{:bar=&gt;3}'>hello</span>\n|)
  end

  it 'renders code attributes' do
    expect(render_string(<<HAML)).to eq(%Q|<span bar='{:hoge=&gt;:fuga}' baz foo='1'>hello</span>\n|)
- attrs = { foo: 1, bar: { hoge: :fuga }, baz: true }
%span{attrs} hello
HAML
  end

  it 'renders nested dstr attributes' do
    expect(render_string(<<'HAML')).to eq(%Q|<span foo='{:bar=&gt;&quot;x1y&quot;}'>hello</span>\n|)
- data = { foo: 1 }
%span{foo: {bar: "x#{1}y"}} hello
HAML
  end

  it 'renders data-id and data-class (#38)' do
    aggregate_failures do
      expect(render_string('%span{data: {id: 1}}')).to eq("<span data-id='1'></span>\n")
      expect(render_string('%span{data: {class: 1}}')).to eq("<span data-class='1'></span>\n")
    end
  end

  it 'converts underscore to hyphen in data attributes' do
    with_each_attribute_type(:data, '{foo_bar: "baz"}') do |str|
      expect(render_string(str)).to eq("<span data-foo-bar='baz'></span>\n")
    end
  end

  describe 'data attributes' do
    it 'renders nested attributes' do
      expect(render_string(%q|%span{data: {foo: 1, bar: 'baz', :hoge => :fuga, k1: { k2: 'v3' }}} hello|)).to eq(%Q{<span data-bar='baz' data-foo='1' data-hoge='fuga' data-k1-k2='v3'>hello</span>\n})
    end

    it 'renders nested dynamic attributes' do
      expect(render_string(%q|%span{data: {foo: "b#{'a'}r"}} hello|)).to eq(%Q{<span data-foo='bar'>hello</span>\n})
    end

    it 'renders nested attributes' do
      expect(render_string(%q|%span{data: {foo: 1, bar: 2+3}} hello|)).to eq(%Q{<span data-bar='5' data-foo='1'>hello</span>\n})
    end

    it 'renders nested code attributes' do
      expect(render_string(<<HAML)).to eq(%Q{<span data-bar='2' data-foo='1'>hello</span>\n})
- data = { foo: 1, bar: 2 }
%span{data: data} hello
HAML
    end

    it 'skips falsey data attributes' do
      expect(render_string('%span{data: { foo: nil }}')).to eq("<span></span>\n")
      expect(render_string("- v = nil\n%span{data: { foo: v }}")).to eq("<span></span>\n")
    end

    it 'skips falsey data attributes after merging attributes' do
      expect(render_string(<<HAML)).to eq("<a></a>\n")
- h1 = { new: true }
- h2 = { data: { old: true } }
%a(data=h1){ h2 , data: { new: nil, old: false } }
HAML
    end

    it 'renders true data attributes' do
      expect(render_string('%span{data: { foo: true }}')).to eq("<span data-foo></span>\n")
      expect(render_string("- v = true\n%span{data: { foo: v }}")).to eq("<span data-foo></span>\n")
    end
  end
end
