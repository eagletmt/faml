# frozen-string-literal: true
require 'spec_helper'

RSpec.describe 'Newline with > and <', type: :render do
  describe '>' do
    it 'parses nuke-outer-whitespace (>)' do
      expect(render_string(<<HAML)).to eq("<img><span>hello</span><img>\n")
%img
%span> hello
%img
HAML

      expect(render_string(<<HAML)).to eq("<div>\n<span>1</span><span>hoge</span></div>\n")
%div
  %span= 1
  %span> hoge
HAML
    end

    it 'handles silent script' do
      expect(render_string(<<HAML)).to eq("<div><span>0</span><span>1</span></div>\n")
%div
  - 2.times do |i|
    %span>= i
HAML
    end

    it 'handles comment' do
      expect(render_string(<<HAML)).to eq("<div>\n<!--<span>0</span><span>1</span>-->\n</div>\n")
%div
  /
    - 2.times do |i|
      %span>= i
HAML
    end

    it 'handles conditional comment' do
      expect(render_string(<<HAML)).to eq("<div>\n<!--[if IE]><span>0</span><span>1</span><![endif]-->\n</div>\n")
%div
  / [if IE]
    - 2.times do |i|
      %span>= i
HAML
    end
  end

  describe '>' do
    it 'parses nuke-inner-whitespace (<)' do
      expect(render_string(<<HAML)).to eq("<blockquote><div>\nFoo!\n</div></blockquote>\n")
%blockquote<
  %div
    Foo!
HAML
    end

    it 'renders pre tag as nuke-inner-whitespace by default' do
      expect(render_string(<<HAML)).to eq("<pre>hello\nworld</pre>\n")
%pre
  hello
  world
HAML
    end

    it 'handles silent script' do
      expect(render_string(<<HAML)).to eq("<div>012</div>\n")
%div<
  - 3.times do |i|
    = i
HAML
    end

    it 'parses texts correctly' do
      expect(render_string('%div{foo: :bar} <b>hello</b>')).to eq("<div foo='bar'><b>hello</b></div>\n")
      expect(render_string('%div(foo="bar") <b>hello</b>')).to eq("<div foo='bar'><b>hello</b></div>\n")
    end
  end

  describe '><' do
    it 'parses nuke-whitespaces' do
      expect(render_string(<<HAML)).to eq("<img><pre>foo\nbar</pre><img>\n")
%img
%pre><
  foo
  bar
%img
HAML
    end

    it 'allows double rmnl' do
      expect(render_string(<<HAML)).to eq('<div><span>hello</span></div>')
%div><
  %span><= 'hello'
HAML
    end
  end
end
