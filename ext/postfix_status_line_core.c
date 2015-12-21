#include "postfix_status_line_core.h"

static rb_postfix_status_line_parse(VALUE self, VALUE str) {
  return Qnil;
}

void Init_postfix_status_line_core() {
  VALUE rb_mPostfixStatusLine = rb_define_module("PostfixStatusLine");
  VALUE rb_mPostfixStatusLineCore = rb_define_module_under(rb_mPostfixStatusLine, "Core");
  rb_define_module_function(rb_mPostfixStatusLineCore, "parse", rb_postfix_status_line_parse, 1);
}
