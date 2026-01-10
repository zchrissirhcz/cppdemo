// writer.cpp - Writer process: create shared memory and write data
#include <Windows.h>
#include <iostream>

int main()
{
    const char* sharedMemName = "Local\\MySharedMemory";
    const int bufSize = 256;

    // Create shared memory
    HANDLE hMapFile = CreateFileMappingA(
        INVALID_HANDLE_VALUE,   // Use system paging file
        NULL,                   // Default security
        PAGE_READWRITE,         // Read/write access
        0,                      // Size high DWORD
        bufSize,                // Size low DWORD
        sharedMemName);         // Name of shared memory

    if (hMapFile == NULL) {
        std::cerr << "CreateFileMapping failed: " << GetLastError() << std::endl;
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

    // Write data
    const char* message = "Hello from writer process!";
    CopyMemory(pBuf, message, strlen(message) + 1);

    std::cout << "Writer: Wrote message \"" << message << "\"" << std::endl;
    std::cout << "Writer: Press Enter to exit (shared memory will be released)..." << std::endl;
    std::cin.get();

    // Cleanup
    UnmapViewOfFile(pBuf);
    CloseHandle(hMapFile);

    return 0;
}
