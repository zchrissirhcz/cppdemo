cmake_minimum_required(VERSION 3.20)
project(demo10)

if(MSVC)
  return()
endif()
zzpkg_find(OpenCV/4.12.0)

add_executable(demo10_writer writer.cpp)
target_link_libraries(demo10_writer PRIVATE ${OpenCV_LIBS})

add_executable(demo10_viewer viewer.cpp)
target_link_libraries(demo10_viewer PRIVATE ${OpenCV_LIBS})