require 'spec_helper'

RSpec.describe 'Comment rendering', type: :render do
  it 'renders html comment' do
    expect(render_string('/ comments')).to eq("<!-- comments -->\n")
  end

  it 'strips spaces' do
    expect(render_string('/   comments   ')).to eq("<!-- comments -->\n")
  end

  it 'renders structured comment' do
    expect(render_string(<<HAML)).to eq("<span>hello</span>\n<!--\ngreat\n-->\n<span>world</span>\n")
%span hello
/
  great
%span world
HAML
  end

  it 'renders comment with interpolation' do
    expect(render_string(<<'HAML')).to eq("<span>hello</span>\n<!--\ngreat\n-->\n<span>world</span>\n")
- comment = 'great'
%span hello
/
  #{comment}
%span world
HAML
  end

  it 'renders conditional comment' do
    expect(render_string('/ [if IE] hello')).to eq("<!--[if IE]> hello <![endif]-->\n")
  end

  it 'renders conditional comment with children' do
    expect(render_string(<<HAML)).to eq("<!--[if IE]>\n<span>hello</span>\nworld\n<![endif]-->\n")
/[if IE]
  %span hello
  world
HAML
  end

  it 'parses nested conditional comment' do
    expect(render_string(<<HAML)).to eq("<!--[[if IE]]>\n<span>hello</span>\nworld\n<![endif]-->\n")
/[[if IE]]
  %span hello
  world
HAML
  end

  it 'raises error if conditional comment bracket is unbalanced' do
    expect { render_string('/[[if IE]') }.to raise_error(HamlParser::Error)
  end

  it 'raises error if both comment text and children are given' do
    expect { render_string(<<HAML) }.to raise_error(HamlParser::Error)
/ hehehe
  %span hello
HAML
  end
end
