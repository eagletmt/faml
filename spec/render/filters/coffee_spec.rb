require 'spec_helper'

RSpec.describe 'CoffeeScript filter rendering', type: :render do
  it 'renders CoffeeScript filter' do
    html = render_string(<<HAML)
:coffee
  square = (x) -> x * x
  square(3)
HAML
    expect(html).to include('<script>')
    expect(html).to include('square = function(x)')
    expect(html).to include('square(3)')
  end

  it 'parses string interpolation' do
    html = render_string(<<'HAML')
:coffee
  square = (x) -> x * x
  square(#{1 + 2})
HAML
    expect(html).to include('<script>')
    expect(html).to include('square = function(x)')
    expect(html).to include('square(3)')
  end
end
