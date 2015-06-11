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

  it 'raises error if the current indent is deeper than the previous one' do
    expect { render_string(<<HAML) }.to raise_error(Faml::IndentTracker::InconsistentIndent) { |e|
%div
  %div
      %div
HAML
      expect(e.previous_size).to eq(2)
      expect(e.current_size).to eq(4)
      expect(e.lineno).to eq(3)
    }
  end

  it 'raises error if the current indent is shallower than the previous one' do
    expect { render_string(<<HAML) }.to raise_error(Faml::IndentTracker::InconsistentIndent) { |e|
%div
    %div
      %div
HAML
      expect(e.previous_size).to eq(4)
      expect(e.current_size).to eq(2)
      expect(e.lineno).to eq(3)
    }
  end

  it 'raises error if indented with hard tabs' do
    expect { render_string(<<HAML) }.to raise_error(Faml::IndentTracker::HardTabNotAllowed)
%p
	%a
HAML
  end
end
