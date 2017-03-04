require 'mkmf'

if have_header('openssl/sha.h')
  if have_library('ssl') and have_library('crypto')
    create_makefile('ext/postfix_status_line_core')
  end
else
  create_makefile('ext/postfix_status_line_core')
end
