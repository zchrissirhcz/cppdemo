#include <opencv2/opencv.hpp>
#include <opencv2/core/utils/logger.hpp>
#include <stdlib.h>
#include "debug_helper.h"

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
    //cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_SILENT);

    std::cout << cv::getBuildInformation() << std::endl; // Add this line

    //return 0;
    const std::string ZZPKG_ROOT = get_zzpkg_root();
    printf("ZZPKG_ROOT: %s\n", ZZPKG_ROOT.c_str());
    //const std::string video_path = ZZPKG_ROOT + "/opencv-src/4.12.0/samples/cpp/tutorial_code/calib3d/real_time_pose_estimation/Data/box.mp4";
    //const std::string video_path = ZZPKG_ROOT + "/h264_data/0.1/3min_1080p.h264";
    const std::string video_path = ZZPKG_ROOT + "/h265_data/0.1/H265_1080P.mp4";
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

        cv::imshow("Video", frame); // breakpoint here
        if (cv::waitKey(30) >= 0)
            break;
        printf("wait\n");
    }

    cv::destroyAllWindows();

    return 0;
}