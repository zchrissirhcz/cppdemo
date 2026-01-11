zzpkg_find(OpenCV/4.12.0:static)

# demo11: OpenCV window in main thread (macOS compatible)
add_executable(demo11 demo11.cpp)
target_link_libraries(demo11 PRIVATE ${OpenCV_LIBS})

# demo11_thread_display: OpenCV window in child thread (test for Windows)
add_executable(demo11_thread_display demo11_thread_display.cpp)
target_link_libraries(demo11_thread_display PRIVATE ${OpenCV_LIBS})