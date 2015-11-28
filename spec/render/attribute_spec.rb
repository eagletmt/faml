# frozen-string-literal: true
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

  it 'strigify non-string classes' do
    expect(render_string('%span.foo{class: :bar} hello')).to eq("<span class='bar foo'>hello</span>\n")
    expect(render_string('%span.foo{class: 1} hello')).to eq("<span class='1 foo'>hello</span>\n")
  end

  it 'strigify non-string ids' do
    expect(render_string('%span#foo{id: :bar} hello')).to eq("<span id='foo_bar'>hello</span>\n")
  end

  it 'escapes' do
    expect(render_string(%q|%span{class: "x\"y'z"} hello|)).to eq(%Q{<span class='x&quot;y&#39;z'>hello</span>\n})
  end

  it 'does not escape slash' do
    expect(render_string(%q|%a{ href: 'http://example.com/' }|)).to eq(%Q{<a href='http://example.com/'></a>\n})
    expect(render_string(%q|%a{ {}, href: 'http://example.com/' }|)).to eq(%Q{<a href='http://example.com/'></a>\n})
  end

  it 'renders only name if value is true' do
    expect(render_string(%q|%span{foo: true, bar: 1} hello|)).to eq(%Q{<span bar='1' foo>hello</span>\n})
  end

  it 'raises error when unparsable Ruby code is given' do
    expect { render_string('%span{x ==== 2}') }.to raise_error(Faml::UnparsableRubyCode)
  end

  context 'with xhtml format' do
    it 'renders name="name" if value is true' do
      expect(render_string(%q|%span{foo: true, bar: 1} hello|, format: :xhtml)).to eq(%Q{<span bar='1' foo='foo'>hello</span>\n})
      expect(render_string(%Q|- foo = true\n%span{foo: foo, bar: 1} hello|, format: :xhtml)).to eq(%Q{<span bar='1' foo='foo'>hello</span>\n})
      expect(render_string(%Q|- h = {foo: true, bar: 1}\n%span{h} hello|, format: :xhtml)).to eq(%Q{<span bar='1' foo='foo'>hello</span>\n})
    end
  end

  it 'renders dstr attributes' do
    expect(render_string(<<HAML)).to eq(%Q|<span data='x{:foo=&gt;1}y'>hello</span>\n|)
- data = { foo: 1 }
%span{data: "x\#{data}y"} hello
HAML
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

  describe 'object reference' do
    it 'renders id and class attribute' do
      expect(render_string('%span[Faml::TestStruct.new(123)] hello')).to eq("<span class='faml_test_struct' id='faml_test_struct_123'>hello</span>\n")
    end

    it 'renders id and class attribute with prefix' do
      expect(render_string('%span[Faml::TestStruct.new(123), :hello] hello')).to eq("<span class='hello_faml_test_struct' id='hello_faml_test_struct_123'>hello</span>\n")
    end

    it 'renders id and class attribute with haml_object_ref' do
      expect(render_string('%span[Faml::TestRefStruct.new(123)] hello')).to eq("<span class='faml_test' id='faml_test_123'>hello</span>\n")
    end

    it 'renders id in correct order' do
      expect(render_string('%span#baz[Faml::TestStruct.new(123)]{id: "foo"} hello')).to eq("<span class='faml_test_struct' id='baz_foo_faml_test_struct_123'>hello</span>\n")
    end
  end

  context 'when old attributes and new attributes have the same key' do
    it 'prefers old attributes' do
      aggregate_failures do
        expect(render_string('%span{foo: 1}(foo=2)')).to eq("<span foo='1'></span>\n")
        expect(render_string('%span(foo=2){foo: 1}')).to eq("<span foo='1'></span>\n")
        expect(render_string("- v = 2\n%span{foo: v-1}(foo=v)")).to eq("<span foo='1'></span>\n")
        expect(render_string("- v = 2\n%span(foo=v){foo: v-1}")).to eq("<span foo='1'></span>\n")
        expect(render_string("- h = {foo: 1}\n%span{h}(foo=2)")).to eq("<span foo='1'></span>\n")
        expect(render_string("- h = {foo: 1}\n%span(foo=2){h}")).to eq("<span foo='1'></span>\n")
      end
    end

    it 'merges class attribute' do
      aggregate_failures do
        expect(render_string('%span{class: 1}(class=2)')).to eq("<span class='1 2'></span>\n")
        expect(render_string("- v = 2\n%span{class: v-1}(class=v)")).to eq("<span class='1 2'></span>\n")
        expect(render_string("- h = {class: 1}\n%span{h}(class=2)")).to eq("<span class='1 2'></span>\n")
      end
    end

    it 'merges id attribute' do
      aggregate_failures do
        expect(render_string('%span{id: 1}(id=2)')).to eq("<span id='2_1'></span>\n")
        expect(render_string('%span(id=2){id: 1}')).to eq("<span id='2_1'></span>\n")
        expect(render_string("- v = 2\n%span{id: v-1}(id=v)")).to eq("<span id='2_1'></span>\n")
        expect(render_string("- v = 2\n%span(id=v){id: v-1}")).to eq("<span id='2_1'></span>\n")
        expect(render_string("- h = {id: 1}\n%span{h}(id=2)")).to eq("<span id='2_1'></span>\n")
        expect(render_string("- h = {id: 1}\n%span(id=2){h}")).to eq("<span id='2_1'></span>\n")
      end
    end
  end
end
