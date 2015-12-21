#include "postfix_status_line_core.h"

static char *split(char **orig_str, char *delim, size_t delim_len) {
  char *str = *orig_str;
  char *ptr = strstr(str, delim);

  if (ptr == NULL) {
    return NULL;
  }

  size_t i;

  for (i = 0; i < delim_len; i++) {
    *ptr = '\0';
    ptr++;
  }

  *orig_str = ptr;

  return str;
}

static int split3(char buf[], char **p1, char **p2, char **p3) {
  char *buf_ptr = buf;

  *p1 = split(&buf_ptr, ": ", 2);

  if (*p1 == NULL) {
    return -1;
  }

  *p2 = split(&buf_ptr, ": ", 2);

  if (*p2 == NULL) {
    return -1;
  }

  *p3 = buf_ptr;

  return 0;
}

static int split_p1(char *str, char **time, char **hostname, char **process) {
  *process = strrchr(str, ' ');

  if (*process == NULL) {
    return -1;
  }

  **process = '\0';
  (*process)++;

  *hostname = strrchr(str, ' ');

  if (*hostname == NULL) {
    return -1;
  }

  if (*hostname - str < 1) {
    return -1;
  }

  **hostname = '\0';
  (*hostname)++;

  *time = str;

  return 0;
}

static int split_line1(char buf[], char **time, char **hostname, char **process, char **queue_id, char **attrs) {
  char *p1, *p2, *p3;

  if (split3(buf, &p1, &p2, &p3) != 0) {
    return -1;
  }

  if (split_p1(p1, time, hostname, process) != 0) {
    return -1;
  }

  *queue_id = p2;
  *attrs = p3;

  return 0;
}

static void mask_email(char *str) {
  int mask = 0;

  while (*str) {
    if (*str == '@') {
      mask = 0;
    } else if (*str == '<') {
      mask = 1;
    } else if (mask) {
      *str = '*';
    }

    str++;
  }
}

static void put_attr(char *str, VALUE hash) {
  char *value = strchr(str, '=');

  if (value == NULL) {
    return;
  }

  *value = '\0';
  value++;

  rb_hash_aset(hash, rb_str_new2(str), rb_str_new2(value));
}

static void split_line2(char *str, int mask, VALUE hash) {
  if (mask) {
    mask_email(str);
  }

  char *ptr;

  for (;;) {
    ptr = split(&str, ", ", 2);

    if (ptr == NULL) {
      break;
    }

    put_attr(ptr, hash);
  }

  if (str) {
    put_attr(str, hash);
  }
}

static VALUE rb_postfix_status_line_parse(VALUE self, VALUE v_str, VALUE v_mask) {
  Check_Type(v_str, T_STRING);

  char *str = RSTRING_PTR(v_str);
  size_t len = RSTRING_LEN(v_str);
  int mask = 1;

  switch (TYPE(v_mask)) {
  case T_FALSE:
  case T_NIL:
    mask = 0;
  }

  if (len < 1) {
    return Qnil;
  }

  char buf[len + 1];
  strncpy(buf, str, len);
  buf[len] = '\0';

  char *time, *hostname, *process, *queue_id, *attrs;

  if (split_line1(buf, &time, &hostname, &process, &queue_id, &attrs) != 0) {
    return Qnil;
  }

  VALUE hash = rb_hash_new();
  rb_hash_aset(hash, rb_str_new2("time"), rb_str_new2(time));
  rb_hash_aset(hash, rb_str_new2("hostname"), rb_str_new2(hostname));
  rb_hash_aset(hash, rb_str_new2("process"), rb_str_new2(process));
  rb_hash_aset(hash, rb_str_new2("queue_id"), rb_str_new2(queue_id));

  split_line2(attrs, mask, hash);

  return hash;
}

void Init_postfix_status_line_core() {
  VALUE rb_mPostfixStatusLine = rb_define_module("PostfixStatusLine");
  VALUE rb_mPostfixStatusLineCore = rb_define_module_under(rb_mPostfixStatusLine, "Core");
  rb_define_module_function(rb_mPostfixStatusLineCore, "parse", rb_postfix_status_line_parse, 2);
}
