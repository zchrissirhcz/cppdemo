#pragma once

#ifdef _DEBUG

#include <windows.h>
#include <iostream>

// 函数指针类型
typedef void(__stdcall* DebugViewFunc)(void*);

class DebugHelper {
private:
    HMODULE hDll;
    DebugViewFunc debugViewFunc;

public:
    DebugHelper() : hDll(nullptr), debugViewFunc(nullptr) {
        hDll = LoadLibraryA("debugview_dll.dll");
        if (hDll) {
            debugViewFunc = (DebugViewFunc)GetProcAddress(hDll, "DebugView");
            if (debugViewFunc) {
                std::cout << "✓ DebugView loaded successfully" << std::endl;
            }
            else {
                std::cout << "✗ DebugView function not found" << std::endl;
            }
        }
        else {
            std::cout << "✗ debugview_dll.dll not loaded (Error: "
                << GetLastError() << ")" << std::endl;
        }
    }

    ~DebugHelper() {
        if (hDll) {
            FreeLibrary(hDll);
        }
    }

    // 便捷调用函数
    void show(cv::Mat& mat) {
        if (debugViewFunc) {
            debugViewFunc(&mat);
        }
    }

    // 获取函数指针（供立即窗口使用）
    DebugViewFunc getFunc() {
        return debugViewFunc;
    }
};

// 全局单例
static DebugHelper g_debugHelper;

// 便捷宏
#define DEBUG_SHOW(mat) g_debugHelper.show(mat)

// 供立即窗口使用的全局函数指针
static DebugViewFunc DebugView = g_debugHelper.getFunc();

#else

// Release 配置下，宏编译为空
#define DEBUG_SHOW(mat)

#endif