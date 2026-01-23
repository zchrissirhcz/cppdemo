#include <opencv2/core/mat.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#ifndef NOMINMAX
#   define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#   define WIN32_LEAN_AND_MEAN
#endif
#include <ghc/filesystem.hpp>
namespace fs = ghc::filesystem;

void rgb2gray_u8(const cv::Mat& src, cv::Mat& dst)
{
    CV_Assert(src.type() == CV_8UC3);
    dst.create(src.size(), CV_8UC1);

    for (int y = 0; y < src.rows; ++y)
    {
        // use fixed point arithmetic for performance
        const uchar* srcRow = src.ptr<uchar>(y);
        uchar* dstRow = dst.ptr<uchar>(y);
        for (int x = 0; x < src.cols; ++x)
        {
            uchar b = srcRow[x * 3 + 0];
            uchar g = srcRow[x * 3 + 1];
            uchar r = srcRow[x * 3 + 2];
            // Gray = 0.299*R + 0.587*G + 0.114*B
            dstRow[x] = static_cast<uchar>((77 * r + 150 * g + 29 * b) >> 8);
        }
    }
}

int test_rgb2gray_u8()
{
    std::string zzpkg_root = std::getenv("ZZPKG_ROOT");
    if (zzpkg_root.empty())
    {
        printf("Environment variable ZZPKG_ROOT is not set.\n");
        return -1; // ZZPKG_ROOT not set
    }
    std::string image_path = zzpkg_root + "/opencv-src/4.12.0/samples/data/lena.jpg";
    if (fs::exists(image_path) == false)
    {
        printf("Image file does not exist: %s\n", image_path.c_str());
        return -1; // Image file does not exist
    }

    cv::Mat src = cv::imread(image_path, cv::IMREAD_COLOR);
    if (src.empty())
    {
        printf("Failed to load image: %s\n", image_path.c_str());
        return -1; // Image not found
    }
    cv::Mat dst;
    rgb2gray_u8(src, dst);
    if (dst.type() != CV_8UC1 || dst.size() != src.size())
    {
        return -2; // Conversion failed
    }
    // save as grayscale image
    cv::imwrite("gray_image.jpg", dst);
    return 0; // Success
}

int main()
{
    test_rgb2gray_u8();
    return 0;
}