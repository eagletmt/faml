require 'spec_helper'

RSpec.describe 'Plain rendering', type: :render do
  it 'outputs literally when prefixed with "\\"' do
    expect(render_string('\= @title')).to eq("= @title\n")
  end
end
