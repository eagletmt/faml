require 'spec_helper'

RSpec.describe FastHaml::Parser, type: :parser do
  describe 'doctype' do
    it 'parses html5 doctype' do
      expect(render_string('!!!')).to eq("<!DOCTYPE html>\n")
    end
  end
end
