# frozen_string_literal: true
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

  it 'allows empty silent script body' do
    expect(render_string("%br\n-\n%br")).to eq("<br>\n<br>\n")
  end

  it 'allows empty else body' do
    expect(render_string(<<HAML)).to eq("ok\nfinish\n")
- if true
  ok
- else
finish
HAML
  end

  it 'allows empty rescue body' do
    expect(render_string(<<HAML)).to eq("finish\n")
- begin
  - raise
- rescue
finish
HAML
  end

  it 'allows empty ensure body' do
    expect(render_string(<<HAML)).to eq("ok\nfinish\n")
- begin
  ok
- ensure
finish
HAML
  end

  it 'checks indent levels' do
    expect(render_string(<<HAML)).to eq("<span>hello</span>\n")
- if true
  %span hello
  - if false
    %span world
- else
  %span !!!
HAML
  end
end
