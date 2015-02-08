require 'spec_helper'

RSpec.describe 'Doctype rendering', type: :render do
  it 'parses html5 doctype' do
    expect(render_string('!!!')).to eq("<!DOCTYPE html>\n")
  end

  it 'ignores 1 or 2 exclamation marks' do
    expect(render_string('!')).to eq("!\n")
    expect(render_string('!!')).to eq("!!\n")
  end
end
