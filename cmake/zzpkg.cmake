if(DEFINED ENV{ZZPKG_ROOT})
  set(ZZPKG_ROOT $ENV{ZZPKG_ROOT})
else()
  set(ZZPKG_ROOT "~/.zzpkg")
endif()
file(TO_CMAKE_PATH "${ZZPKG_ROOT}" ZZPKG_ROOT)


# Set default installation directory
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "" FORCE)
endif()

# Set default RPATH for installed binaries
if(NOT CMAKE_INSTALL_RPATH)
  set(CMAKE_INSTALL_RPATH "$ORIGIN:$ORIGIN/../lib")
endif()

macro(zzpkg_detect_platform)
  # determine platform
  if(NOT ZZPKG_PLATFORM)
    if(ANDROID)
      set(ZZPKG_PLATFORM "android")
    elseif(WIN32)
      set(ZZPKG_PLATFORM "windows")
    elseif(APPLE)
      set(ZZPKG_PLATFORM "mac")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
      set(ZZPKG_PLATFORM "linux")
    else()
      message(FATAL_ERROR "unknown platform: ${CMAKE_SYSTEM_NAME}")
    endif()
  endif()
endmacro()

macro(zzpkg_detect_arch)
  # determine arch
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")
    set(ZZPKG_ARCH "x64")
  elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
    set(ZZPKG_ARCH "arm64")
  else()
    message(FATAL_ERROR "unknown architecture: ${CMAKE_SYSTEM_PROCESSOR}")
  endif()
endmacro()

zzpkg_detect_platform()
zzpkg_detect_arch()

# Macro to find a package given platform-specific root paths
# Usage:
# zzpkg_find([PACKAGE_NAME/PACKAGE_VERSION] # Package name and version, required
#   WINDOWS  "path/to/windows/package"    # Package install path on Windows, optional
#   LINUX    "path/to/linux/package"      # Package install path on Linux, optional
#   ANDROID  "path/to/android/package"    # Package install path on Android, optional
#   MACOS    "path/to/macos/package"      # Package install path on macOS, optional
# )
macro(zzpkg_find PACKAGE_NAME_AND_VERSION)
  # 解析 PACKAGE_NAME_AND_VERSION 为 pkg_name 和 pkg_version
  string(REPLACE "/" ";" _pkg_parts "${PACKAGE_NAME_AND_VERSION}")
  list(LENGTH _pkg_parts _parts_len)
  list(GET _pkg_parts 0 PACKAGE_NAME)
  if(_parts_len GREATER 1)
    list(GET _pkg_parts 1 PACKAGE_VERSION)
  else()
    message(FATAL_ERROR "PACKAGE_NAME_AND_VERSION must be in the format 'PackageName/Version'")
  endif()

  cmake_parse_arguments(
    ARG
    ""
    "WINDOWS;LINUX;ANDROID;MAC;DEFAULT"
    ""
    ${ARGN}
  )

  # Default path construction
  # try 1: if exists `inc` directory under ZZPKG_ROOT/PACKAGE_NAME/PACKAGE_VERSION, treat it as header-only library
  set(PACKAGE_PLATFORM_INDEPENDENT_ROOT "${ZZPKG_ROOT}/${PACKAGE_NAME}/${PACKAGE_VERSION}")
  set(PACKAGE_PLATFORM_DEPENDENT_ROOT "${ZZPKG_ROOT}/${PACKAGE_NAME}/${PACKAGE_VERSION}/${ZZPKG_PLATFORM}-${ZZPKG_ARCH}")
  if(EXISTS "${PACKAGE_PLATFORM_INDEPENDENT_ROOT}/inc")
    set(PACKAGE_ROOT "${PACKAGE_PLATFORM_INDEPENDENT_ROOT}")
    add_library(${PACKAGE_NAME} INTERFACE)
    target_include_directories(${PACKAGE_NAME} INTERFACE "${PACKAGE_PLATFORM_INDEPENDENT_ROOT}/inc")
    set_target_properties(${PACKAGE_NAME} PROPERTIES
      VERSION ${PACKAGE_VERSION}
    )
    add_library(zzpkg::${PACKAGE_NAME} ALIAS ${PACKAGE_NAME})
  elseif(EXISTS ${PACKAGE_PLATFORM_DEPENDENT_ROOT})
    set(PACKAGE_ROOT "${PACKAGE_PLATFORM_DEPENDENT_ROOT}")
    if((ZZPKG_PLATFORM STREQUAL "android") AND ARG_ANDROID)
      set(package_root "${ARG_ANDROID}")
    elseif((ZZPKG_PLATFORM STREQUAL "windows") AND ARG_WINDOWS)
      set(package_root "${ARG_WINDOWS}")
    elseif((ZZPKG_PLATFORM STREQUAL "mac") AND ARG_MAC)
      set(package_root "${ARG_MAC}")
    elseif((ZZPKG_PLATFORM STREQUAL "linux") AND ARG_LINUX)
      set(package_root "${ARG_LINUX}")
    elseif(ARG_DEFAULT)
      set(package_root "${ARG_DEFAULT}")
    else()
      set(package_root "${PACKAGE_ROOT}")
    endif()

    if(NOT package_root)
      message(FATAL_ERROR "No ${PACKAGE_NAME_AND_VERSION} path provided for current platform")
    endif()

    message(STATUS "Searching ${PACKAGE_NAME_AND_VERSION} on ${ZZPKG_PLATFORM}")
    message(STATUS "Root directory: ${package_root}")

    # 常见的 CMake config 文件位置
    set(candidate_subdirs
      ""
      lib/cmake/${PACKAGE_NAME}
      lib/cmake
      share/cmake/${PACKAGE_NAME}
      share/${PACKAGE_NAME}
      cmake/lib
      x64/vc18/lib
      x64/vc17/lib
      x64/vc16/lib
      x64/vc15/lib
      lib
      sdk/native/jni
      sdk/native/jni/abi-${ANDROID_ABI}
      cmake/abi-${ANDROID_ABI}
      cmake
    )

    # 尝试查找 Config 文件
    set(config_found FALSE)
    foreach(subdir ${candidate_subdirs})
      set(config_path "${package_root}/${subdir}")
      set(config_files
        "${config_path}/${PACKAGE_NAME}Config.cmake"
        "${config_path}/${PACKAGE_NAME}-config.cmake"
      )
      foreach(config_file ${config_files})
        if(EXISTS "${config_file}")
          set(${PACKAGE_NAME}_DIR "${config_path}")
          message(STATUS "Found ${PACKAGE_NAME} config in: ${config_path}")
          set(config_found TRUE)
          break()
        endif()
      endforeach()
      if(config_found)
        break()
      endif()
    endforeach()

    if(NOT config_found)
      message(FATAL_ERROR "Could not find ${PACKAGE_NAME}Config.cmake in subdirs of: ${package_root}")
    endif()

    find_package(${PACKAGE_NAME} REQUIRED)
  endif()

  message(STATUS "${PACKAGE_NAME}_FOUND: ${${PACKAGE_NAME}_FOUND}")
  message(STATUS "${PACKAGE_NAME}_VERSION: ${${PACKAGE_NAME}_VERSION}")

  # 清理临时变量
  unset(ARG_WINDOWS)
  unset(ARG_LINUX)
  unset(ARG_ANDROID)
  unset(ARG_MACOS)
  unset(ARG_COMPONENTS)
  unset(ARG_OPTIONAL_COMPONENTS)
  unset(package_root)
  unset(platform_name)
  unset(candidate_subdirs)
  unset(config_found)
  unset(subdir)
  unset(config_path)
  unset(config_files)
  unset(config_file)
  unset(_pkg_parts)
  unset(PACKAGE_NAME)
  unset(PACKAGE_VERSION)
endmacro()
