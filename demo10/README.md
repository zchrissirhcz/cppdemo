image viewer based on shared memory.
writer.cpp 作为 client, 把图像数据写入到共享内存。
reader.cpp 作为 server，读取图像并可视化。
为了每次传递不同大小的图像，约定共享内存中先是 ImageInfo 再是图像像素.