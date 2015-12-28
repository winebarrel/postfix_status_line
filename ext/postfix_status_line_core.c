#include "postfix_status_line_core.h"

#ifdef HAVE_OPENSSL_SHA_H
static void sha512_to_str(unsigned char *hash, char buf[]) {
  int i;

  for (i = 0; i < SHA512_DIGEST_LENGTH; i++) {
    snprintf(buf + (i * 2), 3, "%02x", hash[i]);
  }
}

static bool digest_sha512(char *str, char *salt, size_t salt_len, char buf[]) {
  SHA512_CTX ctx;
  unsigned char hash[SHA512_DIGEST_LENGTH];

  if (SHA512_Init(&ctx) != 1) {
    return false;
  }

  if (SHA512_Update(&ctx, str, strlen(str)) != 1) {
    return false;
  }

  if (salt != NULL) {
    if (SHA512_Update(&ctx, salt, salt_len) != 1) {
      return false;
    }
  }

  if (SHA512_Final(hash, &ctx) != 1) {
    return false;
  }

  sha512_to_str(hash, buf);

  return true;
}
#endif // HAVE_OPENSSL_SHA_H

static bool rb_value_to_bool(VALUE v_value) {
  switch (TYPE(v_value)) {
  case T_FALSE:
  case T_NIL:
    return false;
  default:
    return true;
  }
}

static char *split(char **orig_str, const char *delim, size_t delim_len) {
  char *str = *orig_str;
  char *ptr = strstr((const char *) str, delim);

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

static bool split3(char buf[], char **p1, char **p2, char **p3) {
  char *buf_ptr = buf;

  *p1 = split(&buf_ptr, ": ", 2);

  if (*p1 == NULL) {
    return false;
  }

  *p2 = split(&buf_ptr, ": ", 2);

  if (*p2 == NULL) {
    return false;
  }

  *p3 = buf_ptr;

  return true;
}

static bool split_p1(char *str, char **time, char **hostname, char **process) {
  *process = strrchr(str, ' ');

  if (*process == NULL) {
    return false;
  }

  **process = '\0';
  (*process)++;

  *hostname = strrchr(str, ' ');

  if (*hostname == NULL) {
    return false;
  }

  if (*hostname - str < 1) {
    return false;
  }

  **hostname = '\0';
  (*hostname)++;

  *time = str;

  return true;
}

static bool split_line1(char buf[], char **tm, char **hostname, char **process, char **queue_id, char **attrs) {
  char *p1, *p2, *p3;

  if (!split3(buf, &p1, &p2, &p3)) {
    return false;
  }

  if (!split_p1(p1, tm, hostname, process)) {
    return false;
  }

  *queue_id = p2;
  *attrs = p3;

  return true;
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
    } else if (*str == '<' || *str == '(' || *str == ' ' || *str == ',') {
      ptr = str + 1;
    }

    str++;
  }
}

static char *remove_bracket(char *value) {
  char *email = strchr(value, '<');

  if (email == NULL) {
    return value;
  }

  email++;

  char *close_bracket = strchr(email, '>');

  if (close_bracket != NULL) {
    *close_bracket = '\0';
  }

  return email;
}

static void put_domain(char *value, VALUE hash) {
  char *domain = strchr(value, '@');

  if (domain == NULL) {
    return;
  }

  domain++;

  rb_hash_aset(hash, rb_str_new2("domain"), rb_str_new2(domain));
}

static void put_status(char *value, VALUE hash, bool mask) {
  if (mask) {
    mask_email(value);
  }

  char *detail = strchr(value, ' ');

  if (detail != NULL) {
    *detail = '\0';
    detail++;
    rb_hash_aset(hash, rb_str_new2("status_detail"), rb_str_new2(detail));
  }

  rb_hash_aset(hash, rb_str_new2("status"), rb_str_new2(value));
}

#ifdef HAVE_OPENSSL_SHA_H
static void put_hash(char *email, VALUE hash_obj, char *salt, size_t salt_len) {
  char buf[SHA512_DIGEST_LENGTH * 2 + 1];

  if (!digest_sha512(email, salt, salt_len, buf)) {
    return;
  }

  rb_hash_aset(hash_obj, rb_str_new2("hash"), rb_str_new2(buf));
}
#endif // HAVE_OPENSSL_SHA_H

static void put_to(char *value, VALUE hash, bool mask, bool include_hash, char *salt, size_t salt_len) {
  char *email = remove_bracket(value);

#ifdef HAVE_OPENSSL_SHA_H
  if (include_hash) {
    put_hash(email, hash, salt, salt_len);
  }
#endif

  if (mask) {
    mask_email(value); // not "email"!
  }

  rb_hash_aset(hash, rb_str_new2("to"), rb_str_new2(email));
  put_domain(value, hash);
}

static void put_from(char *value, VALUE hash, bool mask) {
  char *email = remove_bracket(value);

  if (mask) {
    mask_email(value); // not "email"!
  }

  rb_hash_aset(hash, rb_str_new2("from"), rb_str_new2(email));
}

static void put_attr(char *str, VALUE hash, bool mask, bool include_hash, char *salt, size_t salt_len) {
  char *value = strchr(str, '=');

  if (value == NULL) {
    return;
  }

  *value = '\0';
  value++;

  VALUE v_key = rb_str_new2(str);

  if (strcmp(str, "delay") == 0) {
    rb_hash_aset(hash, v_key, rb_float_new(atof(value)));
  } else if (strcmp(str, "conn_use") == 0) {
    rb_hash_aset(hash, v_key, INT2NUM(atoi(value)));
  } else if (strcmp(str, "to") == 0) {
    put_to(value, hash, mask, include_hash, salt, salt_len);
  } else if (strcmp(str, "from") == 0) {
    put_from(value, hash, mask);
  } else if (strcmp(str, "status") == 0) {
    put_status(value, hash, mask);
  } else {
    if (mask) {
      mask_email(value);
    }

    rb_hash_aset(hash, v_key, rb_str_new2(value));
  }
}

static void split_line2(char *str, bool mask, VALUE hash, bool include_hash, char *salt, size_t salt_len) {
  char *ptr;

  for (;;) {
    ptr = split(&str, ", ", 2);

    // status detail includes ", "
    if (strchr(str, '=') == NULL) {
      *(str - 1) = ' ';
      *(str - 2) = ' ';
      str = ptr;
      break;
    }

    if (ptr == NULL) {
      break;
    }

    put_attr(ptr, hash, mask, include_hash, salt, salt_len);
  }

  if (str) {
    put_attr(str, hash, mask, include_hash, salt, salt_len);
  }
}

static int get_year() {
  time_t now = time(NULL);

  if (now == -1) {
    return -1;
  }

  struct tm *t = localtime(&now);

  if (t == NULL) {
    return -1;
  }

  return t->tm_year;
}

static void put_epoch(char *time_str, VALUE hash) {
  time_t ts;
  struct tm parsed;

  if (strptime(time_str, "%b %d %H:%M:%S", &parsed) == NULL) {
    return;
  }

  int this_year = get_year();

  if (this_year == -1) {
    return;
  }

  parsed.tm_year = this_year;
  parsed.tm_isdst = 0;

  ts = mktime(&parsed);

  if (ts == -1) {
    return;
  }

  rb_hash_aset(hash, rb_str_new2("epoch"), LONG2NUM(ts));
}

static VALUE rb_postfix_status_line_parse(VALUE self, VALUE v_str, VALUE v_mask, VALUE v_hash, VALUE v_salt, VALUE v_parse_time) {
  Check_Type(v_str, T_STRING);

  char *str = RSTRING_PTR(v_str);
  size_t len = RSTRING_LEN(v_str);

  if (len < 1) {
    return Qnil;
  }

  bool mask = rb_value_to_bool(v_mask);
  bool parse_time = rb_value_to_bool(v_parse_time);

  bool include_hash = false;
  char *salt = NULL;
  size_t salt_len = -1;

if (rb_value_to_bool(v_hash)) {
#ifdef HAVE_OPENSSL_SHA_H
    include_hash = true;

    if (!NIL_P(v_salt)) {
      Check_Type(v_salt, T_STRING);
      salt = RSTRING_PTR(v_salt);
      salt_len = RSTRING_LEN(v_salt);
    }
#else
    rb_raise(rb_eArgError, "OpenSSL is not linked");
#endif // HAVE_OPENSSL_SHA_H
  }

  char buf[len + 1];
  strncpy(buf, str, len);
  buf[len] = '\0';

  char *tm, *hostname, *process, *queue_id, *attrs;

  if (!split_line1(buf, &tm, &hostname, &process, &queue_id, &attrs)) {
    return Qnil;
  }

  VALUE hash = rb_hash_new();
  rb_hash_aset(hash, rb_str_new2("time"), rb_str_new2(tm));
  rb_hash_aset(hash, rb_str_new2("hostname"), rb_str_new2(hostname));
  rb_hash_aset(hash, rb_str_new2("process"), rb_str_new2(process));
  rb_hash_aset(hash, rb_str_new2("queue_id"), rb_str_new2(queue_id));

  if (parse_time) {
    put_epoch(tm, hash);
  }

  split_line2(attrs, mask, hash, include_hash, salt, salt_len);

  return hash;
}

void Init_postfix_status_line_core() {
  VALUE rb_mPostfixStatusLine = rb_define_module("PostfixStatusLine");
  VALUE rb_mPostfixStatusLineCore = rb_define_module_under(rb_mPostfixStatusLine, "Core");
  rb_define_module_function(rb_mPostfixStatusLineCore, "parse", rb_postfix_status_line_parse, 5);
}
