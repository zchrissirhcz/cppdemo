#include <stdio.h>

#if defined(_MSC_VER) && defined(_MSVC_LANG)
#define MY_CPP_STD _MSVC_LANG   // MSVC 下用真实值
#else
#define MY_CPP_STD __cplusplus  // 其它编译器/开启了 /Zc:__cplusplus
#endif

// 便捷判断
#define MY_CPP14 (MY_CPP_STD >= 201402L)
#define MY_CPP17 (MY_CPP_STD >= 201703L)
#define MY_CPP20 (MY_CPP_STD >= 202002L)
#define MY_CPP23 (MY_CPP_STD >= 202302L)

int main()
{
    printf("_MSVC_LANG is %d\n", _MSVC_LANG);
}