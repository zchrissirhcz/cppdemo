#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#ifdef FOO_EXPORTS
#   if defined(_MSC_VER) || defined(__CYGWIN__) || defined(__MINGW32__)
#       define FOO_API __declspec(dllexport)
#   elif defined(__GNUC__) && __GNUC__ >= 4
#       define FOO_API __attribute__((visibility("default")))
#   endif
#else
#   if defined(_MSC_VER) || defined(__CYGWIN__) || defined(__MINGW32__)
#       define FOO_API __declspec(dllimport)
#   else
#       define FOO_API
#   endif
#endif

typedef struct FooEngine FooEngine;

FOO_API int foo_init(FooEngine** engine);
FOO_API int foo_process(FooEngine* engine, int n);
FOO_API int foo_uninit(FooEngine* engine);

#ifdef __cplusplus
}
#endif