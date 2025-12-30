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
  # 立即解析包名
  string(REPLACE "/" ";" _recipe_parts "${PACKAGE_RECIPE}")
  string(REPLACE ":" ";" _recipe_parts "${_recipe_parts}")
  list(LENGTH _recipe_parts _recipe_parts_len)
  if(_recipe_parts_len LESS 2)
    message(FATAL_ERROR "PACKAGE_RECIPE must be in format 'PackageName/Version[:hint]'")
  endif()
  
  list(GET _recipe_parts 0 PACKAGE_NAME)
  list(GET _recipe_parts 1 PACKAGE_VERSION)
  set(PACKAGE_HINT)
  if(_recipe_parts_len EQUAL 3)
    list(GET _recipe_parts 2 PACKAGE_HINT)
  endif()
  
  message(STATUS "Searching package with recipe: ${PACKAGE_RECIPE}")
  message(STATUS "  PACKAGE_NAME: ${PACKAGE_NAME}")
  message(STATUS "  PACKAGE_VERSION: ${PACKAGE_VERSION}")
  message(STATUS "  PACKAGE_HINT: ${PACKAGE_HINT}")

  # parse major version
  string(REPLACE "." ";" _version_parts "${PACKAGE_VERSION}")
  list(GET _version_parts 0 PACKAGE_VERSION_MAJOR)
  message(STATUS "  PACKAGE_VERSION_MAJOR: ${PACKAGE_VERSION_MAJOR}")

  # 检查是否已导入
  get_property(_pkg_imported GLOBAL PROPERTY ${PACKAGE_NAME}_IMPORTED)
  
  if(_pkg_imported)
    get_property(_pkg_version GLOBAL PROPERTY ${PACKAGE_NAME}_VERSION)
    if(NOT ${_pkg_version} STREQUAL ${PACKAGE_VERSION})
      message(FATAL_ERROR "conflict version: imported(${_pkg_version}) vs to-be-imported(${PACKAGE_VERSION})")
    endif()
    message(STATUS "  Package already imported with same version, continuing to find config...")
  endif()
  
  # 解析参数
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

  # 构建查找路径
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

  set(PACKAGE_FOUND FALSE)
  foreach(PACKAGE_ROOT ${CANDIDATE_PACKAGE_ROOT_LIST})
    if(PACKAGE_FOUND)
      break()
    endif()

    message(STATUS "  Try find package with PACKAGE_ROOT: ${PACKAGE_ROOT}")
    if(EXISTS "${PACKAGE_ROOT}/inc")
      add_library(${PACKAGE_NAME} INTERFACE)
      target_include_directories(${PACKAGE_NAME} INTERFACE "${PACKAGE_PLATFORM_INDEPENDENT_ROOT}/inc")
      set_target_properties(${PACKAGE_NAME} PROPERTIES
        VERSION ${PACKAGE_VERSION}
      )
      add_library(zzpkg::${PACKAGE_NAME} ALIAS ${PACKAGE_NAME})
      message(STATUS "  Created INTERFACE target: zzpkg::${PACKAGE_NAME}")
      set(PACKAGE_FOUND TRUE)
      break()
    endif()
      
    # 常见的 CMake config 文件位置
    set(candidate_subdirs
      ""
      # ncnn, glfw3
      lib/cmake/${PACKAGE_NAME}

      # OpenCV, macOS/Linux, Default; glfw3 macOS, Default
      lib/cmake/${PACKAGE_NAME}${PACKAGE_VERSION_MAJOR}

      lib/cmake
      share/cmake/${PACKAGE_NAME}
      share/${PACKAGE_NAME}

      # OpenCV Windows, OPENCV_CONFIG_INSTALL_PATH="cmake"
      cmake/lib

      # OpenCV Windows, Default
      x64/vc18/lib
      x64/vc17/lib
      x64/vc16/lib
      x64/vc15/lib

      lib

      # OpenCV Android, Default
      sdk/native/jni
      sdk/native/jni/abi-${ANDROID_ABI}
      # OpenCV Android, OPENCV_CONFIG_INSTALL_PATH="cmake"
      cmake/abi-${ANDROID_ABI}

      # OpenCV Windows, BUILD_SHARED_LIBS=OFF, OPENCV_CONFIG_INSTALL_PATH="cmake"
      cmake/staticlib

      # OpenCV Linux, OPENCV_CONFIG_INSTALL_PATH="cmake"
      cmake
    )

    # 尝试查找 Config 文件
    set(candidate_targets
      ${PACKAGE_NAME}${PACKAGE_VERSION_MAJOR} # glfw3
      ${PACKAGE_NAME} # normal
    )
    foreach(targetName ${candidate_targets})
      foreach(subdir ${candidate_subdirs})
        if(PACKAGE_FOUND)
          break()
        endif()
        set(config_path "${PACKAGE_ROOT}/${subdir}")
        set(config_files
          "${config_path}/${targetName}Config.cmake"
          "${config_path}/${targetName}-config.cmake"
        )
        foreach(config_file ${config_files})
          message(STATUS "    Try config file: ${config_file}")
          if(EXISTS "${config_file}")
            set(${targetName}_DIR "${config_path}")
            message(STATUS "  find_package(${targetName}) with config file ${config_file}")
            find_package(${targetName} REQUIRED)
            set(PACKAGE_FOUND TRUE)
            break()
          endif()
        endforeach()
      endforeach()
    endforeach()
  endforeach()

  if(NOT PACKAGE_FOUND)
    message(FATAL_ERROR "Could not find package with recipe: ${PACKAGE_RECIPE}")
  endif()
  
  # 设置全局导入标记
  set_property(GLOBAL PROPERTY ${PACKAGE_NAME}_IMPORTED TRUE)
  set_property(GLOBAL PROPERTY ${PACKAGE_NAME}_VERSION "${PACKAGE_VERSION}")
  set_property(GLOBAL PROPERTY ${PACKAGE_NAME}_RECIPE "${PACKAGE_RECIPE}")
  
  message(STATUS "Successfully imported ${PACKAGE_NAME} (${PACKAGE_RECIPE})")
  
  # 清理变量
  unset(ARG_WINDOWS)
  unset(ARG_LINUX)
  unset(ARG_ANDROID)
  unset(ARG_MAC)
  unset(CUSTOM_PACKAGE_ROOT)
  unset(candidate_subdirs)
  unset(subdir)
  unset(config_path)
  unset(config_files)
  unset(config_file)
  unset(PACKAGE_PLATFORM_INDEPENDENT_ROOT)
  unset(PACKAGE_PLATFORM_DEPENDENT_ROOT)
  unset(PACKAGE_PLATFORM_DEPENDENT_ROOT_WITH_HINT)
  unset(CANDIDATE_PACKAGE_ROOT_LIST)
  unset(PACKAGE_FOUND)
  unset(PACKAGE_ROOT)
  unset(PACKAGE_NAME)
  unset(PACKAGE_VERSION)
  unset(PACKAGE_VERSION_MAJOR)
  unset(PACKAGE_HINT)
  unset(_recipe_parts)
  unset(_recipe_parts_len)
  unset(_pkg_recipe)
  unset(_pkg_imported)
  unset(_pkg_version)
  unset(_version_parts)
  unset(CANDIDATE_PACKAGE_ROOT_LIST)
endmacro()
