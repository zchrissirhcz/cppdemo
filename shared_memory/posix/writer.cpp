// writer.cpp - Writer process: create shared memory and write data (POSIX)
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <cstring>
#include <iostream>

int main()
{
    const char* sharedMemName = "/MySharedMemory";
    const int bufSize = 256;

    // Create shared memory object
    int fd = shm_open(sharedMemName, O_CREAT | O_RDWR, 0666);
    if (fd == -1) {
        std::cerr << "shm_open failed" << std::endl;
        return 1;
    }

    // Set size
    if (ftruncate(fd, bufSize) == -1) {
        std::cerr << "ftruncate failed" << std::endl;
        close(fd);
        return 1;
    }

    // Map to process address space
    char* pBuf = (char*)mmap(NULL, bufSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (pBuf == MAP_FAILED) {
        std::cerr << "mmap failed" << std::endl;
        close(fd);
        return 1;
    }

    // Write data
    const char* message = "Hello from writer process!";
    strcpy(pBuf, message);

    std::cout << "Writer: Wrote message \"" << message << "\"" << std::endl;
    std::cout << "Writer: Press Enter to exit..." << std::endl;
    std::cin.get();

    // Cleanup
    munmap(pBuf, bufSize);
    close(fd);
    shm_unlink(sharedMemName);  // Remove shared memory object

    return 0;
}
