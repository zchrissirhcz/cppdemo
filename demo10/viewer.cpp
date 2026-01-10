#include <cstdio>
#include <fcntl.h> // O_RDONLY
#include <sys/mman.h> // shm_open
#include <stdio.h> // printf
#include <unistd.h> // close
#include <opencv2/opencv.hpp>
#include "image_info.h"

int main()
{
    const char* sharedMemName = "/sharedImage";
    const int bufSize = 1024 * 768 * 3;

    // open existing shared memory object
    int fd = shm_open(sharedMemName, O_RDONLY, 0666);
    if (fd == -1)
    {
        printf("shm_open failed\n");
        printf("Please run writer first!\n");
        return 1;
    }

    // map to process address space (read-only)
    void* pBuf = mmap(NULL, bufSize, PROT_READ, MAP_SHARED, fd, 0);
    if (pBuf == MAP_FAILED)
    {
        printf("mmap failed\n");
        close(fd);
        return 1;
    }

    while (true)
    {
        // read data
        printf("Reader: Read %d bytes from shared memory\n", bufSize);
        ImageInfo imgInfo{};
        memcpy(&imgInfo, pBuf, sizeof(ImageInfo));
        cv::Mat image(imgInfo.height, imgInfo.width, CV_8UC(imgInfo.channels), (char*)pBuf + sizeof(ImageInfo));
        cv::imshow("Shared Image", image);
        cv::waitKey(0);
    }

    // cleanup
    munmap(pBuf, bufSize);
    close(fd);

    return 0;
}