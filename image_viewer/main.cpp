#include <opencv2/opencv.hpp>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <thread>
#include <mutex>
#include <iostream>

struct ImageData {
    int width;
    int height;
    int type;
    std::vector<uint8_t> data;
    bool updated = false;
};

class ImageViewer {
private:
    ImageData img_data_;
    std::mutex mutex_;
    int port_;
    bool running_ = true;

    void server_thread() {
        int server_fd = socket(AF_INET, SOCK_STREAM, 0);
        if (server_fd < 0) {
            std::cerr << "Socket creation failed\n";
            return;
        }

        int opt = 1;
        setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

        sockaddr_in address{};
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port_);

        if (bind(server_fd, (sockaddr*)&address, sizeof(address)) < 0) {
            std::cerr << "Bind failed\n";
            close(server_fd);
            return;
        }

        listen(server_fd, 3);
        std::cout << "✓ Image Viewer listening on port " << port_ << std::endl;

        while (running_) {
            int client_fd = accept(server_fd, nullptr, nullptr);
            if (client_fd < 0) continue;

            // 接收头部: width(4) + height(4) + type(4)
            int header[3];
            if (recv(client_fd, header, sizeof(header), 0) != sizeof(header)) {
                close(client_fd);
                continue;
            }

            int width = header[0];
            int height = header[1];
            int type = header[2];

            // 计算数据大小
            int channels = CV_MAT_CN(type);
            size_t data_size = width * height * channels;

            // 接收图像数据
            std::vector<uint8_t> buffer(data_size);
            size_t received = 0;
            while (received < data_size) {
                ssize_t n = recv(client_fd, buffer.data() + received, 
                                data_size - received, 0);
                if (n <= 0) break;
                received += n;
            }

            if (received == data_size) {
                std::lock_guard<std::mutex> lock(mutex_);
                img_data_.width = width;
                img_data_.height = height;
                img_data_.type = type;
                img_data_.data = std::move(buffer);
                img_data_.updated = true;
                std::cout << "✓ Received image: " << width << "x" << height << std::endl;
            }

            close(client_fd);
        }

        close(server_fd);
    }

public:
    ImageViewer(int port = 9999) : port_(port) {}

    void run() {
        std::thread server([this]() { server_thread(); });
        server.detach();

        cv::namedWindow("Debug Viewer", cv::WINDOW_NORMAL);
        cv::resizeWindow("Debug Viewer", 800, 600);

        cv::Mat placeholder = cv::Mat::zeros(400, 600, CV_8UC3);
        cv::putText(placeholder, "Waiting for image...", cv::Point(150, 200),
                   cv::FONT_HERSHEY_SIMPLEX, 1.0, cv::Scalar(100, 100, 100), 2);
        
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
    std::cout << "Starting Image Viewer..." << std::endl;
    ImageViewer viewer(9999);
    viewer.run();
    return 0;
}