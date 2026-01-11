#include <cstdio>
#include <fcntl.h> // O_RDONLY
#include <sys/mman.h> // shm_open
#include <stdio.h> // printf
#include <unistd.h> // close
#include <thread>
#include <mutex>
#include <atomic>
#include <opencv2/opencv.hpp>
#include "image_info.h"
#include <semaphore.h>

// 线程间共享数据
std::mutex displayMutex;
cv::Mat currentImage;
bool hasNewImage = false;
std::atomic<bool> shouldExit(false);

// 工作线程：从共享内存读取图像
void readerThreadFunc(SharedImage* pBuf, sem_t* mutexSem, sem_t* notifySem)
{
    printf("Reader thread started\n");
    
    while (!shouldExit)
    {
        // 等待 writer 通知
        sem_wait(notifySem);
        
        if (shouldExit) break;
        
        // 读取共享内存
        cv::Mat localImage;
        {
            sem_wait(mutexSem);
            printf("Reader thread: reading image w=%d, h=%d, channels=%d\n", 
                   pBuf->width, pBuf->height, pBuf->channels);
            
            // 验证数据
            if (pBuf->width <= 0 || pBuf->height <= 0 || 
                pBuf->channels <= 0 || pBuf->channels > 4)
            {
                printf("Invalid image info, skipping\n");
                sem_post(mutexSem);
                continue;
            }
            
            cv::Mat sharedImage(pBuf->height, pBuf->width, 
                              CV_8UC(pBuf->channels), pBuf->imgData);
            localImage = sharedImage.clone();
            sem_post(mutexSem);
        }
        
        // 传递给主线程显示
        {
            std::lock_guard<std::mutex> lock(displayMutex);
            currentImage = localImage;
            hasNewImage = true;
        }
    }
    
    printf("Reader thread exited\n");
}

int main()
{
    const char* sharedMemName = "/sharedImage";
    const int bufSize = sizeof(SharedImage);

    // open existing shared memory object
    int fd = shm_open(sharedMemName, O_RDONLY, 0666);
    if (fd == -1)
    {
        printf("shm_open failed\n");
        printf("Please run writer first!\n");
        return 1;
    }

    // map to process address space (read-only)
    SharedImage* pBuf = (SharedImage*)mmap(NULL, bufSize, PROT_READ, MAP_SHARED, fd, 0);
    if (pBuf == MAP_FAILED)
    {
        printf("mmap failed\n");
        close(fd);
        return 1;
    }

    // initialize semaphore
    sem_t* mutexSem = sem_open("/sharedImageMutex", 0);
    sem_t* notifySem = sem_open("/sharedImageNotify", 0);
    if (mutexSem == SEM_FAILED || notifySem == SEM_FAILED)
    {
        printf("sem_open failed\n");
        munmap(pBuf, bufSize);
        close(fd);
        return 1;
    }

    printf("Viewer started. Press ESC to exit.\n");
    
    // 启动读取线程
    std::thread readerThread(readerThreadFunc, pBuf, mutexSem, notifySem);
    
    // 主线程：负责显示 OpenCV 窗口（macOS 要求）
    cv::namedWindow("Shared Image", cv::WINDOW_AUTOSIZE);
    
    while (!shouldExit)
    {
        cv::Mat imageToShow;
        
        // 从工作线程获取图像
        {
            std::lock_guard<std::mutex> lock(displayMutex);
            if (hasNewImage)
            {
                imageToShow = currentImage.clone();
                hasNewImage = false;
                printf("Main thread: displaying new image\n");
            }
        }
        
        // 显示图像
        if (!imageToShow.empty())
        {
            cv::imshow("Shared Image", imageToShow);
        }
        
        // 持续刷新窗口
        int key = cv::waitKey(30);
        if (key == 27)  // ESC 退出
        {
            printf("ESC pressed, exiting...\n");
            shouldExit = true;
        }
    }
    
    // 通知读取线程退出（post一次让它从sem_wait返回）
    sem_post(notifySem);
    readerThread.join();
    
    cv::destroyAllWindows();

    // cleanup
    munmap(pBuf, bufSize);
    close(fd);

    sem_close(mutexSem);
    sem_close(notifySem);

    return 0;
}
