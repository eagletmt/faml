require 'spec_helper'

RSpec.describe 'SilentScript rendering', type: :render do
  it 'parses silent script' do
    expect(render_string(<<HAML)).to eq("<span>0</span>\n<span>1</span>\n")
- 2.times do |i|
  %span= i
HAML
  end

  it 'parses if' do
    expect(render_string(<<HAML)).to eq("<div>\neven\n</div>\n")
%div
  - if 2.even?
    even
HAML
  end

  it 'parses if and text' do
    expect(render_string(<<HAML)).to eq("<div>\neven\nok\n</div>\n")
%div
  - if 2.even?
    even
  ok
HAML
  end

  it 'parses if and else' do
    expect(render_string(<<HAML)).to eq("<div>\nodd\n</div>\n")
%div
  - if 1.even?
    even
  - else
    odd
HAML
  end

  it 'parses if and elsif' do
    expect(render_string(<<HAML)).to eq("<div>\n2\neven\n</div>\n")
%div
  - if 1.even?
    even
  - elsif 2.even?
    2
    even
  - else
    odd
HAML
  end

  it 'parses case-when' do
    expect(render_string(<<HAML)).to eq("<div>\n2\neven\n</div>\n")
%div
  - case
  - when 1.even?
    even
  - when 2.even?
    2
    even
  - else
    else
HAML
  end

  it 'parses Ruby comment' do
    expect(render_string(<<HAML)).to eq("<span>Print me</span>\n")
- # Ruby comment here
%span Print me
HAML
  end

  it 'parses Ruby multiline' do
    expect(render_string(<<HAML)).to eq("<div>\n<span>ne</span>\n</div>\n")
%div
  - if 1 == Complex(2,
3)
    %span eq
  - else
    %span ne
HAML
  end

  it 'raises error if no Ruby code is given' do
    expect { render_string('-') }.to raise_error(FastHaml::SyntaxError)
  end
end
