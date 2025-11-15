#include <stdio.h>

// 测试中文注释
struct Foo {
    int x;
    Foo() = default;
    Foo(int val) : x(val) {}
    const char* s = "你好世界"; // 测试中文字符串能否正常显示，包括调试、打印场景
};

int main()
{
    printf("hello world\n");
    printf("你好世界\n");

    Foo f;
    printf("f.x = %d, f.s = %s\n", f.x, f.s);
    printf("bye\n");
    return 0;
}