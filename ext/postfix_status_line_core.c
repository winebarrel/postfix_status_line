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

static int split_line1(char buf[], char **tm, char **hostname, char **process, char **queue_id, char **attrs) {
  char *p1, *p2, *p3;

  if (split3(buf, &p1, &p2, &p3) != 0) {
    return -1;
  }

  if (split_p1(p1, tm, hostname, process) != 0) {
    return -1;
  }

  *queue_id = p2;
  *attrs = p3;

  return 0;
}

static void mask_email(char *str) {
  char *ptr = NULL;

  while (*str) {
    if (*str == '@' && ptr != NULL) {
      while (ptr < str) {
        *ptr = '*';
        ptr++;
      }

      ptr = NULL;
    } else if (*str == '<') {
      ptr = str + 1;
    }

    str++;
  }
}

static void put_domain(char *value, VALUE hash) {
  char *domain = strchr(value, '@');

  if (domain == NULL) {
    return;
  }

  domain++;

  char *bracket = strchr(domain, '>');
  VALUE v_value;

  if (bracket == NULL) {
    v_value = rb_str_new2(domain);
  } else {
    size_t len = bracket - domain;
    v_value = rb_str_new(domain, len);
  }

  rb_hash_aset(hash, rb_str_new2("domain"), v_value);
}

static void put_status(char *value, VALUE hash) {
  char *reason = strchr(value, ' ');

  if (reason != NULL) {
    *reason = '\0';
    reason++;
    rb_hash_aset(hash, rb_str_new2("status_detail"), rb_str_new2(reason));
  }

  rb_hash_aset(hash, rb_str_new2("status"), rb_str_new2(value));
}

static void put_attr(char *str, VALUE hash) {
  char *value = strchr(str, '=');

  if (value == NULL) {
    return;
  }

  *value = '\0';
  value++;

  VALUE v_key = rb_str_new2(str);

  if (strcmp(str, "delay") == 0) {
    VALUE v_value = rb_float_new(atof(value));
    rb_hash_aset(hash, v_key, v_value);
  } else if (strcmp(str, "status") == 0) {
    put_status(value, hash);
  } else {
    VALUE v_value = rb_str_new2(value);
    rb_hash_aset(hash, v_key, v_value);
  }

  if (strcmp(str, "to") == 0) {
    put_domain(value, hash);
  }
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

static void put_time(char *str, VALUE hash) {
  time_t now = time(NULL);
  struct tm *tm_now = localtime(&now);
  struct tm t;

  if (strptime(str, "%b %d %H:%M:%S", &t) == NULL) {
    return;
  }

  t.tm_year = tm_now->tm_year;
  time_t epoch = mktime(&t);

  if (epoch == -1) {
    return;
  }

  rb_hash_aset(hash, rb_str_new2("time"), LONG2NUM(epoch));
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

  char *tm, *hostname, *process, *queue_id, *attrs;

  if (split_line1(buf, &tm, &hostname, &process, &queue_id, &attrs) != 0) {
    return Qnil;
  }

  VALUE hash = rb_hash_new();
  put_time(tm, hash);
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
