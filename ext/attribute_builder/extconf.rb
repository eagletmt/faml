# frozen-string-literal: true
require 'mkmf'

$CFLAGS << ' -Wall -W'
$CXXFLAGS << ' -Wall -W'
houdini_dir = File.expand_path('../../vendor/houdini', __dir__)
$INCFLAGS << " -I#{houdini_dir}"

$srcs = %w[attribute_builder.cc]
%w[
  buffer.c
  houdini_html_e.c
].each do |c|
  FileUtils.ln_s(File.join(houdini_dir, c), c, force: true)
  $srcs << c
end

create_makefile('faml/attribute_builder')
