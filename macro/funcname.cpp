// MSVC: https://learn.microsoft.com/zh-cn/cpp/preprocessor/predefined-macros?view=msvc-170
// GCC:  https://gcc.gnu.org/onlinedocs/gcc-4.8.2/gcc/Function-Names.html
// https://stackoverflow.com/questions/15305310/predefined-macros-for-function-name-func
// https://www.boost.org/doc/libs/1_78_0/boost/current_function.hpp

// MY_FUNC
#if defined(__GNUC__) || defined(__clang__)
#   define MY_FUNC __PRETTY_FUNCTION__
#elif defined(_MSC_VER)
#   define MY_FUNC __FUNCSIG__
#else
#   define MY_FUNC __func__
#endif

#include <stdio.h>

void hello(const char* name)
{
    //printf("%s\n", MY_FUNC);

#if defined(__GNUC__)
    printf("__PRETTY_FUNCTION__: %s\n", __PRETTY_FUNCTION__);
    #ifdef __PRETTY_FUNCTION__
        printf("__PRETTY_FUNCTION__ is defined: YES\n");
    #else
        printf("__PRETTY_FUNCTION__ is defined: NO\n");
    #endif
#endif

#if defined(_MSC_VER)
    printf("__FUNCSIG__: %s\n", __FUNCSIG__);
    #ifdef __FUNCSIG__
        printf("__FUNCSIG__ is defined: YES\n");
    #else
        printf("__FUNCSIG__ is defined: NO\n");
    #endif

    printf("__FUNCDNAME__: %s\n", __FUNCDNAME__);
#endif

    printf("__func__: %s\n", __func__);
    printf("__FUNCTION__: %s\n", __FUNCTION__);

    printf("hello, %s\n", name);
}

int main()
{
    hello("C++");

    return 0;
}