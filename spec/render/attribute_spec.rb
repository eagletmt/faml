require 'spec_helper'

RSpec.describe 'Attributes rendering', type: :render do
  it 'parses attributes' do
    expect(render_string('%span{class: "x"} hello')).to eq(%Q{<span class='x'>hello</span>\n})
  end

  it 'parses attributes' do
    expect(render_string('%span{class: "x", "old" => 2} hello')).to eq(%Q{<span class='x' old='2'>hello</span>\n})
  end

  it 'renders attributes with symbol literal' do
    expect(render_string("%span{foo: 'baz'}")).to eq("<span foo='baz'></span>\n")
    expect(render_string("%span{:foo => 'baz'}")).to eq("<span foo='baz'></span>\n")
    expect(render_string("%span{:'foo-bar' => 'baz'}")).to eq("<span foo-bar='baz'></span>\n")
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.0')
    it 'renders attributes with 2.2-style symbol literals' do
      expect(render_string(%q|%span{"foo": 'bar'}|)).to eq("<span foo='bar'></span>\n")
      expect(render_string(%Q|- x = 'bar'\n%span{"foo": x}|)).to eq("<span foo='bar'></span>\n")
      expect(render_string(%q|%span{'foo': 'bar'}|)).to eq("<span foo='bar'></span>\n")
      expect(render_string(%Q|- x = 'bar'\n%span{'foo': x}|)).to eq("<span foo='bar'></span>\n")
    end
  end

  it 'renders dynamic attributes' do
    expect(render_string(%q|%span#main{class: "na#{'ni'}ka"} hello|)).to eq(%Q{<span class='nanika' id='main'>hello</span>\n})
  end

  it 'renders array class' do
    expect(render_string('%span.c2{class: "c1"}')).to eq("<span class='c1 c2'></span>\n")
    expect(render_string('%span.c2{class: ["c1", "c3", :c2]}')).to eq("<span class='c1 c2 c3'></span>\n")
  end

  it 'renders boolean attributes' do
    expect(render_string('%input{checked: true}')).to eq("<input checked>\n")
    expect(render_string('%input{checked: false}')).to eq("<input>\n")
    expect(render_string('%input{checked: nil}')).to eq("<input>\n")
    expect(render_string('%input{checked: "a" == "a"}')).to eq("<input checked>\n")
    expect(render_string('%input{checked: "a" != "a"}')).to eq("<input>\n")
    expect(render_string("- x = nil\n%input{checked: x}")).to eq("<input>\n")
    expect(render_string("- h = {checked: true}\n%input{h}")).to eq("<input checked>\n")
    expect(render_string("- h = {checked: false}\n%input{h}")).to eq("<input>\n")
    expect(render_string("- h = {checked: nil}\n%input{h}")).to eq("<input>\n")
  end

  it 'merges classes' do
    expect(render_string(<<HAML)).to eq("<span class='c1 c2 content {}' id='main_id1_id3_id2'>hello</span>\n")
- h1 = {class: 'c1', id: ['id1', 'id3']}
- h2 = {class: [{}, 'c2'], id: 'id2'}
%span#main.content{h1, h2} hello
HAML
  end

  it 'strigify non-string classes' do
    expect(render_string('%span.foo{class: :bar} hello')).to eq("<span class='bar foo'>hello</span>\n")
    expect(render_string('%span.foo{class: 1} hello')).to eq("<span class='1 foo'>hello</span>\n")
  end

  it 'remove duplicated classes' do
    expect(render_string('%span.foo{class: :foo}')).to eq("<span class='foo'></span>\n")
    expect(render_string('%span.foo{class: "foo bar"}')).to eq("<span class='bar foo'></span>\n")
    expect(render_string('%span.foo{class: %w[foo bar]}')).to eq("<span class='bar foo'></span>\n")
  end

  it 'strigify non-string ids' do
    expect(render_string('%span#foo{id: :bar} hello')).to eq("<span id='foo_bar'>hello</span>\n")
  end

  it 'escapes' do
    expect(render_string(%q|%span{class: "x\"y'z"} hello|)).to eq(%Q{<span class='x&quot;y&#39;z'>hello</span>\n})
  end

  it 'renders only name if value is true' do
    expect(render_string(%q|%span{foo: true, bar: 1} hello|)).to eq(%Q{<span bar='1' foo>hello</span>\n})
  end

  it 'raises error when unparsable Ruby code is given' do
    expect { render_string('%span{x ==== 2}') }.to raise_error(Faml::Compiler::UnparsableRubyCode)
  end

  context 'with xhtml format' do
    it 'renders name="name" if value is true' do
      expect(render_string(%q|%span{foo: true, bar: 1} hello|, format: :xhtml)).to eq(%Q{<span bar='1' foo='foo'>hello</span>\n})
      expect(render_string(%Q|- foo = true\n%span{foo: foo, bar: 1} hello|, format: :xhtml)).to eq(%Q{<span bar='1' foo='foo'>hello</span>\n})
      expect(render_string(%Q|- h = {foo: true, bar: 1}\n%span{h} hello|, format: :xhtml)).to eq(%Q{<span bar='1' foo='foo'>hello</span>\n})
    end
  end

  it 'renders nested attributes' do
    expect(render_string(%q|%span{foo: {bar: 1+2}} hello|)).to eq(%Q|<span foo='{:bar=&gt;3}'>hello</span>\n|)
  end

  it 'renders code attributes' do
    expect(render_string(<<HAML)).to eq(%Q|<span bar='{:hoge=&gt;:fuga}' baz foo='1'>hello</span>\n|)
- attrs = { foo: 1, bar: { hoge: :fuga }, baz: true }
%span{attrs} hello
HAML
  end

  it 'renders dstr attributes' do
    expect(render_string(<<HAML)).to eq(%Q|<span data='x{:foo=&gt;1}y'>hello</span>\n|)
- data = { foo: 1 }
%span{data: "x\#{data}y"} hello
HAML
  end

  it 'renders nested dstr attributes' do
    expect(render_string(<<'HAML')).to eq(%Q|<span foo='{:bar=&gt;&quot;x1y&quot;}'>hello</span>\n|)
- data = { foo: 1 }
%span{foo: {bar: "x#{1}y"}} hello
HAML
  end

  it 'optimize send case' do
    expect(render_string('%span{foo: {bar: 1+2}} hello')).to eq("<span foo='{:bar=&gt;3}'>hello</span>\n")
  end

  it 'merges static id' do
    expect(render_string('#foo{id: "bar"} baz')).to eq("<div id='foo_bar'>baz</div>\n")
    expect(render_string('#foo{id: %w[bar baz]} hoge')).to eq("<div id='foo_bar_baz'>hoge</div>\n")
  end

  it 'merges static class' do
    expect(render_string('.foo{class: "bar"} baz')).to eq("<div class='bar foo'>baz</div>\n")
    expect(render_string(<<'HAML')).to eq("<div class='bar foo'>baz</div>\n")
- bar = 'bar'
.foo{class: "#{bar}"} baz
HAML
  end

  it 'converts underscore to hyphen in data attributes' do
    expect(render_string("%span{data: {foo_bar: 'baz'}}")).to eq("<span data-foo-bar='baz'></span>\n")
    expect(render_string("- h = {foo_bar: 'baz'}\n%span{data: h}")).to eq("<span data-foo-bar='baz'></span>\n")
  end

  context 'with data attributes' do
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

    it 'renders true data attributes' do
      expect(render_string('%span{data: { foo: true }}')).to eq("<span data-foo></span>\n")
      expect(render_string("- v = true\n%span{data: { foo: v }}")).to eq("<span data-foo></span>\n")
    end
  end

  it 'renders __LINE__ correctly' do
    expect(render_string(<<HAML)).to eq("<span a='2' b='1'></span>\n")
%span{b: __LINE__,
  a: __LINE__}
HAML
  end

  it 'allows NUL characters' do
    expect(render_string('%span{"foo\0bar" => "hello"}')).to eq("<span foo\0bar='hello'></span>\n")
    expect(render_string(<<'HAML')).to eq("<span foo\0bar='hello'></span>\n")
- val = "hello"
%span{"foo\0bar" => val}
HAML
    expect(render_string(<<'HAML')).to eq("<span foo\0bar='hello'></span>\n")
- key = "foo\0bar"
- val = "hello"
%span{key => val}
HAML
  end
end
