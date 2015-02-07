require 'spec_helper'

RSpec.describe 'Tilt integration' do
  def tilt(str)
    Tilt.new('spec.haml') { str }
  end

  it 'renders with fast_haml' do
    expect(Tilt['spec.haml']).to equal(FastHaml::Tilt)
  end

  it 'renders' do
    expect(tilt('%span= 1+2').render).to eq("<span>3</span>\n")
  end

  it 'renders scope' do
    scope = Class.new do
      def hello
        'world'
      end
    end.new

    expect(tilt('%span= hello').render(scope)).to eq("<span>world</span>\n")
  end

  it 'renders locals' do
    expect(tilt('%span= hello').render(Object.new, hello: 'world')).to eq("<span>world</span>\n")
  end

  it 'renders yield block' do
    expect(tilt('%span= yield').render { 'world' }).to eq("<span>world</span>\n")
  end
end
