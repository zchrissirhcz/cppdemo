set(OpenCV_DIR "C:/pkgs/opencv/4.12.0/x64/vc16/lib")
find_package(OpenCV REQUIRED)

add_executable(demo3 demo3.cpp)
target_link_libraries(demo3 PRIVATE ${OpenCV_LIBS})

# if(MSVC)
#   set_target_properties(
#     demo3 PROPERTIES
#     VS_DEBUGGER_ENVIRONMENT "PATH=C:/pkgs/opencv/4.12.0/x64/vc16/bin;%PATH%"
#   )
# endif()
igl_copy_dll(demo3)