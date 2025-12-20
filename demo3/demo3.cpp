#include <opencv2/opencv.hpp>
#include <opencv2/core/utils/logger.hpp>
#include <stdlib.h>

const std::string get_zzpkg_root()
{
    const char* zzpkg_root_env = std::getenv("ZZPKG_ROOT");
    if (zzpkg_root_env)
        return std::string(zzpkg_root_env);
    else
    {
        // expand '~' to home directory, consider both Unix-like and Windows systems
        const char* home_env = std::getenv("HOME");
        if (!home_env)
            home_env = std::getenv("USERPROFILE"); // for Windows
        if (home_env)
            return std::string(home_env) + "/.zzpkg";
        else
            return "~/.zzpkg"; // fallback, may not work correctly
    }
}

int main()
{
    printf("hello world\n");

    // Silence OpenCV internal logger
    cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_SILENT);

    const std::string ZZPKG_ROOT = get_zzpkg_root();
    printf("ZZPKG_ROOT: %s\n", ZZPKG_ROOT.c_str());
    const std::string video_path = ZZPKG_ROOT + "/opencv-src/4.12.0/samples/cpp/tutorial_code/calib3d/real_time_pose_estimation/Data/box.mp4";
    printf("video_path: %s\n", video_path.c_str());

    cv::VideoCapture cap(video_path);
    if (!cap.isOpened())
    {
        printf("Error opening video file: %s\n", video_path.c_str());
        return -1;
    }

    cv::Mat frame;
    int frame_idx = 0;
    while (true)
    {
        printf("Reading frame %d\n", frame_idx++);
        cap >> frame;
        if (frame.empty())
        {
            printf("frame is empty\n");
            break;
        }

        cv::imshow("Video", frame);
        if (cv::waitKey(30) >= 0)
            break;
    }

    cv::destroyAllWindows();

    return 0;
}