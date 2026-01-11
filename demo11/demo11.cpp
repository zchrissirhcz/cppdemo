#include <thread>
#include <mutex>
#include <atomic>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <chrono>

// 全局共享数据
std::mutex displayMutex;
cv::Mat currentImage;
bool hasNewImage = false;
std::atomic<bool> shouldExit(false);

// 工作线程：模拟生成图像数据（后续替换为从共享内存读取）
void workerThreadFunc()
{
    std::cout << "Worker thread started\n";
    
    const std::vector<std::string> colors = {"Red", "Green", "Blue", "Yellow"};
    const std::vector<cv::Scalar> colorValues = {
        cv::Scalar(0, 0, 255),    // Red
        cv::Scalar(0, 255, 0),    // Green
        cv::Scalar(255, 0, 0),    // Blue
        cv::Scalar(0, 255, 255)   // Yellow
    };
    
    int imageIndex = 0;
    while (!shouldExit)
    {
        // 模拟等待信号量（后续替换为 sem_wait）
        std::this_thread::sleep_for(std::chrono::seconds(2));
        
        if (shouldExit) break;
        
        // 生成测试图像
        cv::Mat newImage(480, 640, CV_8UC3, colorValues[imageIndex % 4]);
        cv::putText(newImage, 
                   colors[imageIndex % 4] + " Frame " + std::to_string(imageIndex),
                   cv::Point(50, 240),
                   cv::FONT_HERSHEY_SIMPLEX,
                   1.5,
                   cv::Scalar(255, 255, 255),
                   2);
        
        // 传递给主线程显示
        {
            std::lock_guard<std::mutex> lock(displayMutex);
            currentImage = newImage;
            hasNewImage = true;
        }
        
        std::cout << "Worker thread: generated image " << imageIndex << "\n";
        imageIndex++;
    }
    
    std::cout << "Worker thread exited\n";
}

int main()
{
    std::cout << "Starting demo11 - Multi-threaded OpenCV display (macOS compatible)\n";
    std::cout << "Press ESC in the window to exit\n";
    
    // 在主线程创建窗口
    cv::namedWindow("Image Display", cv::WINDOW_AUTOSIZE);
    
    // 启动工作线程
    std::thread workerThread(workerThreadFunc);
    
    // 主线程：负责显示（必须在主线程，macOS要求）
    while (!shouldExit)
    {
        cv::Mat imageToShow;
        
        // 从共享变量获取图像
        {
            std::lock_guard<std::mutex> lock(displayMutex);
            if (hasNewImage)
            {
                imageToShow = currentImage.clone();
                hasNewImage = false;
                std::cout << "Main thread: displaying new image\n";
            }
        }
        
        // 显示图像
        if (!imageToShow.empty())
        {
            cv::imshow("Image Display", imageToShow);
        }
        
        // 持续刷新窗口，检测按键
        int key = cv::waitKey(30);
        if (key == 27)  // ESC 退出
        {
            std::cout << "ESC pressed, exiting...\n";
            shouldExit = true;
        }
    }
    
    // 等待工作线程结束
    workerThread.join();
    cv::destroyAllWindows();
    std::cout << "Program exited\n";
    
    return 0;
}
