require 'spec_helper'

RSpec.describe 'Indent', type: :render do
  it 'raises error if indent is wrong' do
    expect { render_string(<<HAML) }.to raise_error(Faml::IndentTracker::IndentMismatch) { |e|
%div
    %div
        %div
  %div
HAML
      expect(e.current_level).to eq(2)
      expect(e.indent_levels).to eq([0])
      expect(e.lineno).to eq(4)
    }
  end
end
