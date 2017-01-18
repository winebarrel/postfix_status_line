#ifndef __POSTFIX_STATUS_LINE_CORE_H__
#define __POSTFIX_STATUS_LINE_CORE_H__

#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE
#endif

#include <stdbool.h>
#include <time.h>

typedef bool (*DIGEST_SHA)(char *, char *, size_t, char[]);

#ifdef HAVE_OPENSSL_SHA_H
#include <openssl/sha.h>
#include "digest_sha.h"
#endif

#include <ruby.h>

#endif //__POSTFIX_STATUS_LINE_CORE_H__
