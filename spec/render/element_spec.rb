# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Element rendering', type: :render do
  it 'parses one-line element' do
    expect(render_string('%span hello')).to eq("<span>hello</span>\n")
  end

  it 'parses multi-line element' do
    expect(render_string(<<HAML)).to eq("<span>\nhello\n</span>\n")
%span
  hello
HAML
  end

  it 'parses nested elements' do
    expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\n</b>\n<i>\n<small>world</small>\n</i>\n</span>\n")
%span
  %b
    hello
  %i
    %small world
HAML
  end

  it 'skips empty lines' do
    expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\n</b>\n</span>\n")
%span

  %b

    hello

HAML
  end

  it 'parses classes' do
    expect(render_string('%span.foo.bar hello')).to eq("<span class='foo bar'>hello</span>\n")
  end

  it 'parses id' do
    expect(render_string('%span#foo-bar hello')).to eq("<span id='foo-bar'>hello</span>\n")
  end

  it 'parses classes and id' do
    expect(render_string('%span.foo#foo-bar.bar hello')).to eq("<span class='foo bar' id='foo-bar'>hello</span>\n")
  end

  it 'parses #' do
    expect(render_string('#main')).to eq("<div id='main'></div>\n")
  end

  it 'parses .' do
    expect(render_string('.wrapper.main')).to eq("<div class='wrapper main'></div>\n")
  end

  it 'parses string interpolation' do
    expect(render_string(%q|%span hello <span> #{'</span>'} </span>|)).to eq("<span>hello <span> &lt;/span&gt; </span></span>\n")
    expect(render_string(<<'HAML')).to eq("<span>\nhello <span> &lt;/span&gt; </span>\n</span>\n")
%span
  hello <span> #{{text: '</span>'}[:text]} </span>
HAML
    expect(render_string(<<'HAML')).to eq("<span>\nhello <span> &lt;/span&gt; </span>\n</span>\n")
- @var = '</span>'
%span
  hello <span> #@var </span>
HAML
  end

  it 'parses string interpolation with multibyte characters' do
    expect(render_string(%q|#{'日本語'} にほんご|)).to eq("日本語 にほんご\n")
  end

  it 'recognized escaped string interpolation' do
    expect(render_string(%q|%p hello \#{1 + 2}|)).to eq("<p>hello \#{1 + 2}</p>\n")
  end

  it 'parses self-closing tag' do
    expect(render_string('%p/')).to eq("<p>\n")
  end

  it 'renders some attributes as self-closing by default' do
    expect(render_string('%meta{"http-equiv" => "Content-Type", :content => "text/html"}')).to eq("<meta content='text/html' http-equiv='Content-Type'>\n")
  end
end
