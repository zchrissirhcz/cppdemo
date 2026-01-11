#pragma once

#define MAX_IMAGE_WIDTH 7680
#define MAX_IMAGE_HEIGHT 4320
#define MAX_IMAGE_CHANNELS 4
#define MAX_IMAGE_BUF_SIZE (MAX_IMAGE_HEIGHT * MAX_IMAGE_WIDTH * MAX_IMAGE_CHANNELS)

// only support 8bit depth image
#pragma pack(push, 1)
struct SharedImage
{
    int width;
    int height;
    int channels;
    unsigned char imgData[MAX_IMAGE_BUF_SIZE];
};
#pragma pack(pop)
