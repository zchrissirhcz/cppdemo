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
macro(zzpkg_find PACKAGE_RECIPE)
  message(STATUS "Searching recipe ${PACKAGE_RECIPE} on platform ${ZZPKG_PLATFORM}")
  # 解析 PACKAGE_RECIPE 为 pkg_name、pkg_version 和 pkg_hint (可选)
  string(REPLACE "/" ";" _recipe_parts "${PACKAGE_RECIPE}")
  string(REPLACE ":" ";" _recipe_parts "${_recipe_parts}")
  list(LENGTH _recipe_parts _recipe_parts_len)  
  if(_recipe_parts_len LESS 2)
    message(FATAL_ERROR "PACKAGE_RECIPE must be in the format 'PackageName/Version[:hint]'")
  endif()
  list(GET _recipe_parts 0 PACKAGE_NAME)
  list(GET _recipe_parts 1 PACKAGE_VERSION)
  set(PACKAGE_HINT)
  if(_recipe_parts_len EQUAL 3)
    list(GET _recipe_parts 2 PACKAGE_HINT)
  endif()

  message(STATUS "  PACKAGE_NAME: ${PACKAGE_NAME}")
  message(STATUS "  PACKAGE_VERSION: ${PACKAGE_VERSION}")
  message(STATUS "  PACKAGE_HINT: ${PACKAGE_HINT}")

  cmake_parse_arguments(
    ARG
    ""
    "WINDOWS;LINUX;ANDROID;MAC;DEFAULT"
    ""
    ${ARGN}
  )

  if((ZZPKG_PLATFORM STREQUAL "android") AND ARG_ANDROID)
    set(CUSTOM_PACKAGE_ROOT "${ARG_ANDROID}")
  elseif((ZZPKG_PLATFORM STREQUAL "windows") AND ARG_WINDOWS)
    set(CUSTOM_PACKAGE_ROOT "${ARG_WINDOWS}")
  elseif((ZZPKG_PLATFORM STREQUAL "mac") AND ARG_MAC)
    set(CUSTOM_PACKAGE_ROOT "${ARG_MAC}")
  elseif((ZZPKG_PLATFORM STREQUAL "linux") AND ARG_LINUX)
    set(CUSTOM_PACKAGE_ROOT "${ARG_LINUX}")
  elseif(ARG_DEFAULT)
    set(CUSTOM_PACKAGE_ROOT "${ARG_DEFAULT}")
  else()
    set(CUSTOM_PACKAGE_ROOT)
  endif()

  # Default path construction
  # try 1: if exists `inc` directory under ZZPKG_ROOT/PACKAGE_NAME/PACKAGE_VERSION, treat it as header-only library
  set(PACKAGE_PLATFORM_INDEPENDENT_ROOT "${ZZPKG_ROOT}/${PACKAGE_NAME}/${PACKAGE_VERSION}")
  set(PACKAGE_PLATFORM_DEPENDENT_ROOT "${ZZPKG_ROOT}/${PACKAGE_NAME}/${PACKAGE_VERSION}/${ZZPKG_PLATFORM}-${ZZPKG_ARCH}")
  set(PACKAGE_PLATFORM_DEPENDENT_ROOT_WITH_HINT "${PACKAGE_PLATFORM_DEPENDENT_ROOT}")
  if(PACKAGE_HINT)
    STRING(APPEND PACKAGE_PLATFORM_DEPENDENT_ROOT_WITH_HINT "-${PACKAGE_HINT}")
  endif()

  message(STATUS "  PACKAGE_PLATFORM_INDEPENDENT_ROOT: ${PACKAGE_PLATFORM_INDEPENDENT_ROOT}")
  message(STATUS "  PACKAGE_PLATFORM_DEPENDENT_ROOT: ${PACKAGE_PLATFORM_DEPENDENT_ROOT}")
  message(STATUS "  PACKAGE_PLATFORM_DEPENDENT_ROOT_WITH_HINT: ${PACKAGE_PLATFORM_DEPENDENT_ROOT_WITH_HINT}")

  set(CANDIDATE_PACKAGE_ROOT_LIST)
  if(CUSTOM_PACKAGE_ROOT)
    list(APPEND CANDIDATE_PACKAGE_ROOT_LIST ${CUSTOM_PACKAGE_ROOT})
  endif()
  if(PACKAGE_HINT)
    list(APPEND CANDIDATE_PACKAGE_ROOT_LIST ${PACKAGE_PLATFORM_DEPENDENT_ROOT_WITH_HINT})
  endif()
  list(APPEND CANDIDATE_PACKAGE_ROOT_LIST ${PACKAGE_PLATFORM_DEPENDENT_ROOT})
  list(APPEND CANDIDATE_PACKAGE_ROOT_LIST ${PACKAGE_PLATFORM_INDEPENDENT_ROOT})

  foreach(PACKAGE_ROOT ${CANDIDATE_PACKAGE_ROOT_LIST})
    message(STATUS "  Try find package with PACKAGE_ROOT: ${PACKAGE_ROOT}")
    if(EXISTS "${PACKAGE_ROOT}/inc")
      add_library(${PACKAGE_NAME} INTERFACE)
      target_include_directories(${PACKAGE_NAME} INTERFACE "${PACKAGE_PLATFORM_INDEPENDENT_ROOT}/inc")
      set_target_properties(${PACKAGE_NAME} PROPERTIES
        VERSION ${PACKAGE_VERSION}
      )
      add_library(zzpkg::${PACKAGE_NAME} ALIAS ${PACKAGE_NAME})
      message(STATUS "  Created INTERFACE target: zzpkg::${PACKAGE_NAME}")
      break()
    endif()
    # message(STATUS "[debug] not a interface library")
      
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
      cmake/staticlib
      cmake
    )

    # 尝试查找 Config 文件
    set(config_found FALSE)
    foreach(subdir ${candidate_subdirs})
      set(config_path "${PACKAGE_ROOT}/${subdir}")
      set(config_files
        "${config_path}/${PACKAGE_NAME}Config.cmake"
        "${config_path}/${PACKAGE_NAME}-config.cmake"
      )
      foreach(config_file ${config_files})
        # message(STATUS "[debug] config_file: ${config_file}")
        if(EXISTS "${config_file}")
          set(${PACKAGE_NAME}_DIR "${config_path}")
          message(STATUS "  Found ${PACKAGE_NAME} config file in: ${config_path}")
          set(config_found TRUE)
          break()
        endif()
      endforeach()
      if(config_found)
        find_package(${PACKAGE_NAME} REQUIRED)
        message(STATUS "  Found package by using find_package()")
        break()
      endif()
    endforeach()
  endforeach()

  # if(NOT config_found)
  #   message(FATAL_ERROR "Could not find ${PACKAGE_NAME}Config.cmake in subdirs of: ${package_root}")
  # endif()

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
  unset(_recipe_parts)
  unset(PACKAGE_NAME)
  unset(PACKAGE_VERSION)
  unset(PACKAGE_HINT)
  unset(PACKAGE_ROOT)
endmacro()
