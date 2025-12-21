#include <opencv2/opencv.hpp>
#include <thread>
#include <mutex>
#include <iostream>
#include <cstring>

// 平台相关的头文件
#ifdef _WIN32
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #pragma comment(lib, "ws2_32.lib")
    typedef SOCKET socket_t;
    #define CLOSE_SOCKET closesocket
    #define SOCKET_ERROR_CHECK(s) ((s) == INVALID_SOCKET)
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <unistd.h>
    typedef int socket_t;
    #define CLOSE_SOCKET close
    #define SOCKET_ERROR_CHECK(s) ((s) < 0)
    #define INVALID_SOCKET -1
#endif

struct ImageData {
    int width = 0;
    int height = 0;
    int type = 0;
    std::vector<uint8_t> data;
    bool updated = false;
};

class ImageViewer {
private:
    ImageData img_data_;
    std::mutex mutex_;
    int port_;
    bool running_ = true;

    bool init_socket_lib() {
#ifdef _WIN32
        WSADATA wsaData;
        return WSAStartup(MAKEWORD(2, 2), &wsaData) == 0;
#else
        return true;
#endif
    }

    void cleanup_socket_lib() {
#ifdef _WIN32
        WSACleanup();
#endif
    }

    void server_thread() {
        if (!init_socket_lib()) {
            std::cerr << "Socket library initialization failed\n";
            return;
        }

        socket_t server_fd = socket(AF_INET, SOCK_STREAM, 0);
        if (SOCKET_ERROR_CHECK(server_fd)) {
            std::cerr << "Socket creation failed\n";
            cleanup_socket_lib();
            return;
        }

        // 设置 SO_REUSEADDR
        int opt = 1;
#ifdef _WIN32
        setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt));
#else
        setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
#endif

        sockaddr_in address{};
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port_);

        if (bind(server_fd, (sockaddr*)&address, sizeof(address)) < 0) {
            std::cerr << "Bind failed\n";
            CLOSE_SOCKET(server_fd);
            cleanup_socket_lib();
            return;
        }

        listen(server_fd, 3);
        std::cout << "✓ Image Viewer listening on port " << port_ << std::endl;

        while (running_) {
            socket_t client_fd = accept(server_fd, nullptr, nullptr);
            if (SOCKET_ERROR_CHECK(client_fd)) continue;

            // 接收头部: width(4) + height(4) + type(4)
            int header[3];
            int header_size = sizeof(header);
            
#ifdef _WIN32
            int received = recv(client_fd, (char*)header, header_size, 0);
#else
            ssize_t received = recv(client_fd, header, header_size, 0);
#endif
            
            if (received != header_size) {
                CLOSE_SOCKET(client_fd);
                continue;
            }

            int width = header[0];
            int height = header[1];
            int type = header[2];

            // 验证数据合法性
            if (width <= 0 || height <= 0 || width > 10000 || height > 10000) {
                std::cerr << "Invalid dimensions: " << width << "x" << height << std::endl;
                CLOSE_SOCKET(client_fd);
                continue;
            }

            // 计算数据大小
            int channels = CV_MAT_CN(type);
            size_t data_size = (size_t)width * height * channels;

            // 接收图像数据
            std::vector<uint8_t> buffer(data_size);
            size_t total_received = 0;
            
            while (total_received < data_size) {
#ifdef _WIN32
                int n = recv(client_fd, (char*)buffer.data() + total_received,
                            (int)(data_size - total_received), 0);
#else
                ssize_t n = recv(client_fd, buffer.data() + total_received,
                                data_size - total_received, 0);
#endif
                if (n <= 0) break;
                total_received += n;
            }

            if (total_received == data_size) {
                std::lock_guard<std::mutex> lock(mutex_);
                img_data_.width = width;
                img_data_.height = height;
                img_data_.type = type;
                img_data_.data = std::move(buffer);
                img_data_.updated = true;
                std::cout << "✓ Received: " << width << "x" << height 
                         << " (" << channels << " ch)" << std::endl;
            } else {
                std::cerr << "Incomplete data: " << total_received 
                         << "/" << data_size << std::endl;
            }

            CLOSE_SOCKET(client_fd);
        }

        CLOSE_SOCKET(server_fd);
        cleanup_socket_lib();
    }

public:
    ImageViewer(int port = 9999) : port_(port) {}

    void run() {
        std::thread server([this]() { server_thread(); });
        server.detach();

        cv::namedWindow("Debug Viewer", cv::WINDOW_NORMAL);
        cv::resizeWindow("Debug Viewer", 800, 600);

        cv::Mat placeholder = cv::Mat::zeros(400, 600, CV_8UC3);
        cv::putText(placeholder, "Waiting for image...", cv::Point(120, 200),
                   cv::FONT_HERSHEY_SIMPLEX, 1.2, cv::Scalar(100, 100, 100), 2);
        
        cv::Mat current_image = placeholder.clone();

        while (true) {
            {
                std::lock_guard<std::mutex> lock(mutex_);
                if (img_data_.updated) {
                    cv::Mat img(img_data_.height, img_data_.width, 
                               img_data_.type, img_data_.data.data());
                    current_image = img.clone();
                    img_data_.updated = false;
                }
            }

            cv::imshow("Debug Viewer", current_image);
            
            int key = cv::waitKey(30);
            if (key == 27) break;  // ESC to quit
        }

        running_ = false;
        cv::destroyAllWindows();
    }
};

int main() {
    std::cout << "==================================" << std::endl;
    std::cout << "  Debug Image Viewer" << std::endl;
#ifdef _WIN32
    std::cout << "  Platform: Windows" << std::endl;
#elif __APPLE__
    std::cout << "  Platform: macOS" << std::endl;
#else
    std::cout << "  Platform: Linux" << std::endl;
#endif
    std::cout << "==================================" << std::endl;
    std::cout << "Press ESC to quit" << std::endl;
    std::cout << std::endl;

    ImageViewer viewer(9999);
    viewer.run();
    return 0;
}