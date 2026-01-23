zzpkg_find(OpenCV/4.12.0:static)
zzpkg_find(ghc-filesystem/1.5.14)

add_executable(rgb2gray rgb2gray.cpp)
target_link_libraries(rgb2gray PRIVATE ${OpenCV_LIBS} zzpkg::ghc-filesystem)
