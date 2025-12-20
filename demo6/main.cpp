#if _MSC_VER
#include <Windows.h>
#include <windef.h>
#endif
#include <stdio.h>

// Win32 style structure definition example
//
// typedef struct tagPOINT
// {
//     LONG  x;
//     LONG  y;
// } POINT, *PPOINT, NEAR *NPPOINT, FAR *LPPOINT;

int main()
{
#if _MSC_VER
    printf("_MSVC_LANG is %d\n", _MSVC_LANG);
#endif
}
