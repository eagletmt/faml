# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Doctype rendering', type: :render do
  context 'with html format' do
    it 'renders html5 doctype by default' do
      expect(render_string('!!!')).to eq("<!DOCTYPE html>\n")
    end

    it 'renders xml doctype (silent)' do
      expect(render_string('!!! xml')).to eq("\n")
    end
  end

  context 'with html4 format' do
    it 'renders transitional doctype by default' do
      expect(render_string('!!!', format: :html4)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n|)
    end

    it 'renders frameset doctype' do
      expect(render_string('!!! frameset', format: :html4)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">\n|)
    end

    it 'renders strict doctype' do
      expect(render_string('!!! strict', format: :html4)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n|)
    end
  end

  context 'with xhtml format' do
    it 'renders transitional doctype by default' do
      expect(render_string('!!!', format: :xhtml)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n|)
    end

    it 'renders xml doctype' do
      expect(render_string('!!! xml', format: :xhtml)).to eq("<?xml version='1.0' encoding='utf-8' ?>\n")
    end

    it 'renders xhtml 1.1 doctype' do
      expect(render_string('!!! 1.1', format: :xhtml)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">\n|)
    end

    it 'renders xhtml mobile doctype' do
      expect(render_string('!!! mobile', format: :xhtml)).to eq(%Q|<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">\n|)
    end

    it 'renders xhtml basic doctype' do
      expect(render_string('!!! basic', format: :xhtml)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">\n|)
    end

    it 'renders xhtml frameset doctype' do
      expect(render_string('!!! frameset', format: :xhtml)).to eq(%Q|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">\n|)
    end

    it 'renders html 5 doctype with xhtml syntax' do
      expect(render_string('!!! 5', format: :xhtml)).to eq(%Q|<!DOCTYPE html>\n|)
    end
  end
end
