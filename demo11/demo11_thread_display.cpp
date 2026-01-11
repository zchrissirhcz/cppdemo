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

// 显示线程：在子线程中运行 OpenCV 窗口（Windows可以，macOS不行）
void displayThreadFunc()
{
    std::cout << "Display thread started (thread ID: " << std::this_thread::get_id() << ")\n";
    cv::namedWindow("Image Display", cv::WINDOW_AUTOSIZE);
    
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
                std::cout << "Display thread: got new image\n";
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
    
    cv::destroyAllWindows();
    std::cout << "Display thread exited\n";
}

int main()
{
    std::cout << "Starting demo11_thread_display - OpenCV in child thread\n";
    std::cout << "Main thread ID: " << std::this_thread::get_id() << "\n";
    std::cout << "Press ESC in the window to exit\n\n";
    std::cout << "Testing if OpenCV window works in child thread...\n";
    std::cout << "Expected: Works on Windows, Crashes on macOS\n\n";
    
    // 启动显示线程
    std::thread displayThread(displayThreadFunc);
    
    // 主线程：模拟生成图像数据
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
        // 生成测试图像
        cv::Mat newImage(480, 640, CV_8UC3, colorValues[imageIndex % 4]);
        cv::putText(newImage, 
                   colors[imageIndex % 4] + " Frame " + std::to_string(imageIndex),
                   cv::Point(50, 240),
                   cv::FONT_HERSHEY_SIMPLEX,
                   1.5,
                   cv::Scalar(255, 255, 255),
                   2);
        
        // 传递给显示线程
        {
            std::lock_guard<std::mutex> lock(displayMutex);
            currentImage = newImage;
            hasNewImage = true;
        }
        
        std::cout << "Main thread: generated image " << imageIndex << "\n";
        imageIndex++;
        
        // 模拟每2秒生成一张新图
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
    
    // 等待显示线程结束
    displayThread.join();
    std::cout << "Program exited\n";
    
    return 0;
}
