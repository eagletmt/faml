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
end
