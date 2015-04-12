require 'mkmf'

$CFLAGS << ' -Wall -W'
create_makefile('faml/attribute_builder')
