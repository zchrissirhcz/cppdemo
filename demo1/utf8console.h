#pragma once

#if _MSC_VER
#ifndef WIN32_LEAN_AND_MEAN
#   define WIN32_LEAN_AND_MEAN
#endif
#include <Windows.h>

namespace {

struct UTF8Console {
    UTF8Console() {
        SetConsoleOutputCP(65001);
        SetConsoleCP(65001);
    }
} g_utf8console_instance;

} // namespace

#endif // _MSC_VER