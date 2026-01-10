#include <fcntl.h> // O_CREAT, O_RDWR
#include <sys/mman.h> // shm_open
#include <unistd.h> // ftruncate, close
#include <stdio.h> // printf
#include <stdlib.h> // getenv
#include <string.h> // strerror
#include <errno.h> // errno
#include <string>
#include <opencv2/opencv.hpp>
#include "image_info.h"

int main()
{
    const char* sharedMemName = "/sharedImage";
    const int bufSize = 1024 * 768 * 3;

    // clean up any existing shared memory object
    shm_unlink(sharedMemName);

    // create shared memory object
    int fd = shm_open(sharedMemName, O_CREAT | O_RDWR, 0666);
    if (fd == -1)
    {
        printf("shm_open failed\n");
        return 1;
    }

    // set size
    if (ftruncate(fd, bufSize) == -1)
    {
        printf("ftruncate failed: %s (errno=%d)\n", strerror(errno), errno);
        printf("Attempted size: %d bytes (%.2f MB)\n", bufSize, bufSize / 1024.0 / 1024.0);
        close(fd);
        shm_unlink(sharedMemName); // clean up
        return 1;
    }

    // map to process address space
    void* pBuf = mmap(NULL, bufSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (pBuf == MAP_FAILED)
    {
        printf("mmap failed\n");
        close(fd);
        return 1;
    }

    // write data
    const char* zzpkg_root = getenv("ZZPKG_ROOT");
    if (zzpkg_root == nullptr)
    {
        printf("Environment variable ZZPKG_ROOT not set\n");
        return 1;
    }
    std::string image_dir = std::string(zzpkg_root) + "/opencv-src/4.12.0/samples/data";

    const std::vector<std::string> image_files = {
        "lena.jpg",
        "sudoku.png",
        "orange.jpg"
    };
    for (const auto& file: image_files)
    {
        std::string const image_path = image_dir + "/" + file;
        printf("Loading image file %s\n", image_path.c_str());
        cv::Mat image = cv::imread(image_path);
        if (image.empty())
        {
            printf("Failed to load image at %s\n", image_path.c_str());
            continue;
        }
        printf("image info: w=%d, h=%d, channels=%d\n", image.cols, image.rows, image.channels());
        if (image.total() * image.elemSize() > bufSize)
        {
            printf("Image size exceeds shared memory buffer size\n");
            continue;
        }
        //memcpy(pBuf, image.data, bufSize);
        ImageInfo imgInfo{};
        imgInfo.width = image.cols;
        imgInfo.height = image.rows;
        imgInfo.channels = image.channels();
        memcpy(pBuf, &imgInfo, sizeof(ImageInfo));
        memcpy((char*)pBuf + sizeof(ImageInfo), image.data, image.total() * image.elemSize());

        printf("Writer: Wrote image data to shared memory\n");
        printf("Writer: Press Enter to write next image...\n");
        getchar();
    }

    printf("Writer: Press Enter to exit...\n");

    // cleanup
    munmap(pBuf, bufSize);
    close(fd);
    shm_unlink(sharedMemName);

    return 0;
}