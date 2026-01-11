image viewer based on shared memory.
writer.cpp 作为 client, 把图像数据写入到共享内存。
viewer.cpp 作为 server，读取图像并可视化。
为了每次传递不同大小的图像，约定共享内存中先是 ImageInfo 再是图像像素.
为了避免读取到撕裂的图像，并且不阻塞写入图像到共享内存的过程，使用信号量+单缓冲.
    - 为了避免同时读写共享内存，共享内存仅作为数据交换缓冲使用，writer把实际数据拷进去， viewer 把数据拷出来再使用
    - 拷贝数据时用的信号量作为 mutex 而存在， 另外还需要一个通知数据更新的信号量
    - 由于数据不大，拷贝耗时可以接受，不会让 viewer 明显阻塞 writer， 因此不使用双缓冲
    - viewer 使用双线程，主线程用 imshow 显示， 子线程负责从共享内存同步给到主线程, imshow 在 macOS 下只能在主线程使用