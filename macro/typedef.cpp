#include <stdint.h>
#include "cxx11.h"

#define MY_DEFINE_STRUCT(_name) typedef struct _name _name; struct _name

#ifdef MY_CXX11
#   define MY_DEFINE_ENUM(_name) enum _name : int32_t
#   define MY_DEFINE_ENUM_EX(_name, _type) enum _name : _type
#else
#   define MY_DEFINE_ENUM(_name) typedef int32_t _name; enum
#   define MY_DEFINE_ENUM_EX(_name, _type) typedef _type _name; enum
#endif

MY_DEFINE_STRUCT(Point)
{
    int x;
    int y;
};

MY_DEFINE_ENUM(Gear)
{
    GEAR_NEUTRAL,
    GEAR_DRIVE,
    GEAR_PARKING,
    GEAR_REVERSE
};

#include <stdio.h>

// make `x` as string, without expanding `x`
#define STRINGIFY_(x) #x

// first expand `x` then make it as string
#define STRINGIFY(x) STRINGIFY_(x)

int main()
{
#ifdef MY_CXX11
    printf("MY_CXX11 is defined\n");
#endif
    printf("__cplusplus: %s\n", STRINGIFY(__cplusplus));
    printf("_MSC_VER: %s\n", STRINGIFY(_MSC_VER));

    return 0;
}