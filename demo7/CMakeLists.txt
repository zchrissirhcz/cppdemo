zzpkg_find(ncnn/master)
zzpkg_find(OpenCV/4.12.0)

add_executable(demo7 main.cpp)
target_link_libraries(demo7 PRIVATE ncnn ${OpenCV_LIBS})
zzpkg_copy_dll(demo7)
