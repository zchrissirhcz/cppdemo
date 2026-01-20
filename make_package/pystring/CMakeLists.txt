cmake_minimum_required(VERSION 3.10)
project(pystring LANGUAGES CXX VERSION 1.1.4)

option (BUILD_SHARED_LIBS "Build shared libraries (set to OFF to build static libs)" ON)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND PROJECT_IS_TOP_LEVEL)
  set (CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist" CACHE PATH
       "Installation location" FORCE)
endif()
message (STATUS "Installation path will be ${CMAKE_INSTALL_PREFIX}")

add_library(pystring
  pystring.cpp
  pystring.h
)
set_target_properties(pystring PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
)

# 让导出目标在 build/install 两种情况下都能找到头文件
include(GNUInstallDirs)
target_include_directories(pystring
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
)

add_executable(pystring_test test.cpp)
target_link_libraries(pystring_test PRIVATE pystring)

enable_testing()
add_test(NAME PyStringTest COMMAND pystring_test)

# 安装库 + 导出 targets
install(TARGETS pystring
  EXPORT pystringTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
)

install(FILES pystring.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
  COMPONENT developer
)

# 安装导出文件 pystringTargets.cmake
install(EXPORT pystringTargets
  NAMESPACE pystring::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pystring
)

# 生成并安装 pystringConfig.cmake / pystringConfigVersion.cmake
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/pystringConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pystringConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/pystringConfig.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pystring
)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/pystringConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/pystringConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pystring
)