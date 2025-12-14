cmake_minimum_required(VERSION 3.25)
project(demo)

######################################################################
# Global settings
# must be set before any targets are defined
######################################################################

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Correctly print UTF-8 characters in MSVC output console
if(MSVC)
  add_compile_options("/source-charset:utf-8")
endif()

include(cmake/igl_copy_dll.cmake)
include(cmake/zzpkg.cmake)

######################################################################
# Define targets
######################################################################
add_subdirectory(demo1)
add_subdirectory(demo2)
add_subdirectory(demo3)
add_subdirectory(demo4)
add_subdirectory(demo5)
add_subdirectory(demo6)