#include "foo.h"
#include <stdio.h>

int main()
{
    FooEngine* engine = nullptr;
    int ret = foo_init(&engine);
    if (ret != 0) return ret;

    int n = 0;
    n = foo_process(engine, 2);
    printf("n = %d\n", n);

    n = foo_process(engine, 3);
    printf("n = %d\n", n);
    
    n = foo_process(engine, 4);
    printf("n = %d\n", n);

    ret = foo_uninit(engine);
    if (ret != 0) return ret;

    return 0;
}