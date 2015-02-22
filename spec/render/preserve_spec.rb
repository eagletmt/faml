require 'spec_helper'

RSpec.describe 'Preserve rendering', type: :render do
  it 'parses preserved script' do
    expect(render_string('~ "<p>hello\nworld</p>"')).to eq("&lt;p&gt;hello\nworld&lt;/p&gt;\n")
    expect(render_string('%span~ "<p>hello\nworld</p>"')).to eq("<span>&lt;p&gt;hello\nworld&lt;/p&gt;</span>\n")
  end

  context 'with unescape-html' do
    it 'keeps newlines within preserve tags' do
      expect(render_string('!~ "<p>hello\n<pre>pre\nworld</pre></p>"')).to eq("<p>hello\n<pre>pre&#x000A;world</pre></p>\n")
      expect(render_string('%span!~ "<p>hello\n<pre>pre\nworld</pre></p>"')).to eq("<span><p>hello\n<pre>pre&#x000A;world</pre></p></span>\n")
    end
  end
end
