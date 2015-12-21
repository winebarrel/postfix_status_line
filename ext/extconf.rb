require 'mkmf'
$CFLAGS += ' -Wdeclaration-after-statement'
create_makefile('ext/postfix_status_line_core')
