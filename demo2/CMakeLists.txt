set(ncnn_DIR "C:/pkgs/ncnn/20250916/windows-vs2022-shared/x64/lib/cmake/ncnn")
find_package(ncnn REQUIRED)

add_executable(demo2 demo2.cpp)
target_link_libraries(demo2 PRIVATE ncnn)

# if(MSVC)
#   set_target_properties(
#     demo2 PROPERTIES
#     VS_DEBUGGER_ENVIRONMENT "PATH=C:/pkgs/ncnn/20250916/windows-vs2022-shared/x64/bin;%PATH%"
#   )
# endif()
igl_copy_dll(demo2)