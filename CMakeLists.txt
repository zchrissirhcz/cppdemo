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

######################################################################
# Define targets
######################################################################
add_executable(demo demo.cpp)
