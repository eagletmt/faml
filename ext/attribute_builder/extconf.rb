# frozen-string-literal: true
require 'mkmf'

$CFLAGS << ' -Wall -W'
if $CXXFLAGS
  # $CXXFLAGS might be undefined
  # https://github.com/ruby/ruby/pull/492
  $CXXFLAGS << ' -Wall -W'
end
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
