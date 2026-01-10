// reader.cpp - Reader process: open shared memory and read data (POSIX)
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <iostream>

int main()
{
    const char* sharedMemName = "/MySharedMemory";
    const int bufSize = 256;

    // Open existing shared memory object
    int fd = shm_open(sharedMemName, O_RDONLY, 0666);
    if (fd == -1) {
        std::cerr << "shm_open failed" << std::endl;
        std::cerr << "Please run writer first!" << std::endl;
        return 1;
    }

    // Map to process address space (read-only)
    char* pBuf = (char*)mmap(NULL, bufSize, PROT_READ, MAP_SHARED, fd, 0);
    if (pBuf == MAP_FAILED) {
        std::cerr << "mmap failed" << std::endl;
        close(fd);
        return 1;
    }

    // Read data
    std::cout << "Reader: Got message \"" << pBuf << "\"" << std::endl;

    // Cleanup
    munmap(pBuf, bufSize);
    close(fd);

    return 0;
}
