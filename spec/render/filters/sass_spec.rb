require 'spec_helper'

RSpec.describe 'SASS filter rendering', type: :render do
  it 'renders SASS filter' do
    html = render_string(<<'HAML')
:sass
  nav
    ul
      margin: 0
      content: "hello"
HAML
    expect(html).to include('<style>')
    expect(html).to include('nav ul {')
    expect(html).to include('content: "hello"')
  end

   it 'parses string interpolation' do
    html = render_string(<<'HAML')
:sass
  nav
    ul
      margin: #{0 + 5}px
HAML
    expect(html).to include('<style>')
    expect(html).to include('nav ul {')
    expect(html).to include('margin: 5px')
  end
end
