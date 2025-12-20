#include <stdio.h>

#if defined(_MSC_VER) && defined(_MSVC_LANG)
#define MY_CPP_STD _MSVC_LANG   // MSVC 下用真实值
#else
#define MY_CPP_STD __cplusplus  // 其它编译器/开启了 /Zc:__cplusplus
#endif

// 便捷判断
#define MY_CPP98 (MY_CPP_STD >= 199711L)
#define MY_CPP11 (MY_CPP_STD >= 201103L)
#define MY_CPP14 (MY_CPP_STD >= 201402L)
#define MY_CPP17 (MY_CPP_STD >= 201703L)
#define MY_CPP20 (MY_CPP_STD >= 202002L)
#define MY_CPP23 (MY_CPP_STD >= 202302L)
#define MY_CPP26 (MY_CPP_STD >= 202602L)

int main()
{
    printf("MY_CPP_STD: %ld\n", MY_CPP_STD);
    printf("MY_CPP98: %d\n", MY_CPP98);
    printf("MY_CPP11: %d\n", MY_CPP11);
    printf("MY_CPP14: %d\n", MY_CPP14);
    printf("MY_CPP17: %d\n", MY_CPP17);
    printf("MY_CPP20: %d\n", MY_CPP20);
    printf("MY_CPP23: %d\n", MY_CPP23);
    printf("MY_CPP26: %d\n", MY_CPP26);

    return 0;
}