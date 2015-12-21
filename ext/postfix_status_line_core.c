#include "postfix_status_line_core.h"

void Init_postfix_status_line_core() {
  VALUE rb_mPostfixStatusLine = rb_define_module("PostfixStatusLine");
  rb_define_module_under(rb_mPostfixStatusLine, "Core");
}
