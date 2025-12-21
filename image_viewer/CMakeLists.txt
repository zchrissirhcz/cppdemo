zzpkg_find(OpenCV/4.12.0)
add_executable(image_viewer main.cpp)
target_link_libraries(image_viewer PRIVATE ${OpenCV_LIBS})