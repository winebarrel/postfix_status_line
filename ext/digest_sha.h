#ifndef __DIGEST_SHA_H__
#define __DIGEST_SHA_H__

#ifndef SHA1_CTX
#define SHA1_CTX SHA_CTX
#endif

#ifndef SHA1_DIGEST_LENGTH
#define SHA1_DIGEST_LENGTH SHA_DIGEST_LENGTH
#endif

#ifndef SHA224_CTX
#define SHA224_CTX SHA256_CTX
#endif

#ifndef SHA384_CTX
#define SHA384_CTX SHA512_CTX
#endif

#define DEFINE_SHA_FUNCTIONS(SHA_ALGO) \
  static void sha##SHA_ALGO##_to_str(unsigned char *hash, char buf[]) { \
    int i; \
    for (i = 0; i < SHA##SHA_ALGO##_DIGEST_LENGTH; i++) { \
      snprintf(buf + (i * 2), 3, "%02x", hash[i]); \
    } \
  } \
  static bool digest_sha##SHA_ALGO(char *str, char *salt, size_t salt_len, char buf[]) { \
    SHA##SHA_ALGO##_CTX ctx; \
    unsigned char hash[SHA##SHA_ALGO##_DIGEST_LENGTH]; \
    if (SHA##SHA_ALGO##_Init(&ctx) != 1) { \
      return false; \
    } \
    if (SHA##SHA_ALGO##_Update(&ctx, str, strlen(str)) != 1) { \
      return false; \
    } \
    if (salt != NULL) { \
      if (SHA##SHA_ALGO##_Update(&ctx, salt, salt_len) != 1) { \
        return false; \
      } \
    } \
    if (SHA##SHA_ALGO##_Final(hash, &ctx) != 1) { \
      return false; \
    } \
    sha##SHA_ALGO##_to_str(hash, buf); \
    return true; \
  }

#endif // __DIGEST_SHA_H__
