#include <opencv2/opencv.hpp>
#include <opencv2/core/utils/logger.hpp>

int main()
{
    // Silence OpenCV internal logger
    cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_SILENT);

    const std::string video_path = R"(C:\pkgs\opencv-src\4.12.0\samples\cpp\tutorial_code\calib3d\real_time_pose_estimation\Data\box.mp4)";
    cv::VideoCapture cap(video_path);
    if (!cap.isOpened())
    {
        printf("Error opening video file: %s\n", video_path.c_str());
        return -1;
    }

    cv::Mat frame;
    while (true)
    {
        cap >> frame;
        if (frame.empty())
            break;

        cv::imshow("Video", frame);
        if (cv::waitKey(30) >= 0)
            break;
    }

    cv::destroyAllWindows();

    return 0;
}