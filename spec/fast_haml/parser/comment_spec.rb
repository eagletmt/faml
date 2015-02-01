require 'spec_helper'

RSpec.describe FastHaml::Parser, type: :parser do
  describe 'comment' do
    it 'renders html comment' do
      expect(render_string('/ comments')).to eq("<!-- comments -->\n")
    end

    it 'strips spaces' do
      expect(render_string('/   comments   ')).to eq("<!-- comments -->\n")
    end
  end
end
