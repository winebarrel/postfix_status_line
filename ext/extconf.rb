require 'mkmf'
$CFLAGS += ' -std=c99'
create_makefile('ext/postfix_status_line_core')
