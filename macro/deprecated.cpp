// MSVC:
//      cl /W3 deprecated.cpp
// warning level {W3, W4, Wall} is required to show deprecated message

#if defined(__GNUC__)
#   define MY_DEPRECATED(msg) __attribute__((deprecated))
#elif defined(_MSC_VER)
#   define MY_DEPRECATED(msg) __declspec(deprecated(msg))
#else
#   define MY_DEPRECATED(msg)
#endif

#include <stdio.h>

MY_DEPRECATED("Use hello() instead")
void helo(const char* msg)
{
    printf("helo, %s\n", msg);
}

void hello(const char* msg)
{
    printf("hello, %s\n", msg);   
}

int main()
{
    helo("world");
    hello("world");
}