#include "foo.h"

struct FooEngine {
    int value;
};

int foo_init(FooEngine** engine)
{
    if (!engine) return -1;
    *engine = new FooEngine();
    (*engine)->value = 0;
    return 0;
}

int foo_process(FooEngine* engine, int n)
{
    if (!engine) return -1;
    engine->value += n;
    return engine->value;
}

int foo_uninit(FooEngine* engine)
{
    if (!engine) return -1;
    delete engine;
    return 0;
}