require 'mkmf'
$CFLAGS += ' -Wno-error=declaration-after-statement'
create_makefile('ext/postfix_status_line_core')
