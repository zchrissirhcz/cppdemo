#include <opencv2/opencv.hpp>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#pragma comment(lib, "ws2_32.lib")

// 初始化 Winsock（只需一次）
static bool InitWinsock() {
    static bool initialized = false;
    if (!initialized) {
        WSADATA wsaData;
        if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
            return false;
        }
        initialized = true;
    }
    return true;
}

// 发送 cv::Mat 到查看器
extern "C" __declspec(dllexport) void __stdcall DebugView(void* mat_ptr) {
    if (!mat_ptr) {
        OutputDebugStringA("DebugView: NULL pointer\n");
        return;
    }

    if (!InitWinsock()) {
        OutputDebugStringA("DebugView: Winsock init failed\n");
        return;
    }

    try {
        cv::Mat* pMat = (cv::Mat*)mat_ptr;
        
        if (pMat->empty()) {
            OutputDebugStringA("DebugView: Empty matrix\n");
            return;
        }

        // 创建 socket
        SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (sock == INVALID_SOCKET) {
            OutputDebugStringA("DebugView: Socket creation failed\n");
            return;
        }

        // 连接到查看器
        sockaddr_in server{};
        server.sin_family = AF_INET;
        server.sin_port = htons(9999);
        inet_pton(AF_INET, "127.0.0.1", &server.sin_addr);

        if (connect(sock, (sockaddr*)&server, sizeof(server)) == SOCKET_ERROR) {
            OutputDebugStringA("DebugView: Connection failed. Is viewer running?\n");
            closesocket(sock);
            return;
        }

        // 发送头部：width, height, type
        int header[3] = { pMat->cols, pMat->rows, pMat->type() };
        send(sock, (char*)header, sizeof(header), 0);

        // 发送图像数据
        size_t data_size = pMat->total() * pMat->elemSize();
        send(sock, (char*)pMat->data, (int)data_size, 0);

        closesocket(sock);

        // 输出调试信息
        char msg[256];
        sprintf_s(msg, "DebugView: Sent %dx%d image (%d channels)\n", 
                  pMat->cols, pMat->rows, pMat->channels());
        OutputDebugStringA(msg);

    } catch (...) {
        OutputDebugStringA("DebugView: Exception occurred\n");
    }
}

// 重载版本：接受地址
extern "C" __declspec(dllexport) void __stdcall DebugViewAddr(unsigned __int64 addr) {
    DebugView((void*)addr);
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
        InitWinsock();
        break;
    case DLL_PROCESS_DETACH:
        WSACleanup();
        break;
    }
    return TRUE;
}