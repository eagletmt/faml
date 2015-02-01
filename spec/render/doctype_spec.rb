require 'spec_helper'

RSpec.describe 'Doctype rendering', type: :render do
  it 'parses html5 doctype' do
    expect(render_string('!!!')).to eq("<!DOCTYPE html>\n")
  end
end
