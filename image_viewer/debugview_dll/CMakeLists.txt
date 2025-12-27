cmake_minimum_required(VERSION 3.15)
project(debugview_dll)

set(CMAKE_CXX_STANDARD 11)

# 查找 OpenCV
zzpkg_find(OpenCV/4.12.0)

# 创建 DLL
add_library(debugview_dll SHARED debugview_dll.cpp)

#target_include_directories(debugview_dll PRIVATE ${OpenCV_INCLUDE_DIRS})
target_link_libraries(debugview_dll ${OpenCV_LIBS} ws2_32)

# 生成 .def 文件以确保符号导出
target_compile_definitions(debugview_dll PRIVATE DEBUGVIEW_EXPORTS)

# 输出到固定位置
set_target_properties(debugview_dll PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)