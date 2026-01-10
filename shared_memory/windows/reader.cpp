// reader.cpp - Reader process: open shared memory and read data
#include <Windows.h>
#include <iostream>

int main()
{
    const char* sharedMemName = "Local\\MySharedMemory";
    const int bufSize = 256;

    // Open existing shared memory
    HANDLE hMapFile = OpenFileMappingA(
        FILE_MAP_ALL_ACCESS,    // Read/write access
        FALSE,                  // Do not inherit handle
        sharedMemName);         // Name of shared memory

    if (hMapFile == NULL) {
        std::cerr << "OpenFileMapping failed: " << GetLastError() << std::endl;
        std::cerr << "Please run writer first!" << std::endl;
        return 1;
    }

    // Map to current process address space
    char* pBuf = (char*)MapViewOfFile(
        hMapFile,
        FILE_MAP_ALL_ACCESS,
        0, 0, bufSize);

    if (pBuf == NULL) {
        std::cerr << "MapViewOfFile failed: " << GetLastError() << std::endl;
        CloseHandle(hMapFile);
        return 1;
    }

    // Read data
    std::cout << "Reader: Got message \"" << pBuf << "\"" << std::endl;

    // Cleanup
    UnmapViewOfFile(pBuf);
    CloseHandle(hMapFile);

    return 0;
}
