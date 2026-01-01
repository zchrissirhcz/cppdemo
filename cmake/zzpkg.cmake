# Author: Zhuo Zhang <imzhuo@foxmail.com>

cmake_minimum_required(VERSION 3.15)
include_guard()

macro(zzpkg_set_root)
  if(DEFINED ENV{ZZPKG_ROOT})
    set(ZZPKG_ROOT $ENV{ZZPKG_ROOT})
  else()
    set(ZZPKG_ROOT "~/.zzpkg")
  endif()
  file(TO_CMAKE_PATH "${ZZPKG_ROOT}" ZZPKG_ROOT)
  set(ZZPKG_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")
endmacro()


# determine target os
macro(zzpkg_detect_os)
  string(TOLOWER "${CMAKE_SYSTEM_NAME}" ZZPKG_OS)
  if(ZZPKG_OS STREQUAL "darwin")
    set(ZZPKG_OS "mac")
  endif()
  if(NOT(ZZPKG_OS MATCHES "^(windows|android|linux|mac)$"))
    message(FATAL_ERROR "unknown platform: ${ZZPKG_OS}")
  endif()
endmacro()

# determine target platform
macro(zzpkg_detect_platform)
  if(NOT ZZPKG_PLATFORM)
    set(ZZPKG_PLATFORM ${ZZPKG_OS})
  endif()
endmacro()

# determine target arch
macro(zzpkg_detect_arch)
  string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" ZZPKG_ARCH)
  if(ZZPKG_ARCH MATCHES "i[3-6]86$")
    set(ZZPKG_ARCH "x86")
  elseif(ZZPKG_ARCH MATCHES "^(x86_64|amd64)$")
    set(ZZPKG_ARCH "x64")
  elseif(ZZPKG_ARCH MATCHES "^(arm64|armv64-v8a)$")
    set(ZZPKG_ARCH "aarch64")
  elseif(ZZPKG_ARCH STREQUAL "armeabi-v7a")
    set(ZZPKG_ARCH "arm")
  else()
    message(FATAL_ERROR "unknown architecture: ${CMAKE_SYSTEM_PROCESSOR}")
  endif()
endmacro()

function(zzpkg_parse_recipe PACKAGE_RECIPE OUT_NAME OUT_VERSION OUT_HINT)
  # 解析配方
  string(REPLACE "/" ";" _recipe_parts "${PACKAGE_RECIPE}")
  string(REPLACE ":" ";" _recipe_parts "${_recipe_parts}")
  list(LENGTH _recipe_parts _recipe_parts_len)
  
  if(_recipe_parts_len LESS 2)
    message(FATAL_ERROR "PACKAGE_RECIPE must be in format 'PackageName/Version[:hint]'")
  endif()
  
  list(GET _recipe_parts 0 _name)
  list(GET _recipe_parts 1 _version)
  set(_hint "")
  
  if(_recipe_parts_len EQUAL 3)
    list(GET _recipe_parts 2 _hint)
  endif()

  # 关键：使用 ${OUT_NAME} 来引用传入的变量名
  set(${OUT_NAME} ${_name} PARENT_SCOPE)
  set(${OUT_VERSION} ${_version} PARENT_SCOPE)
  set(${OUT_HINT} ${_hint} PARENT_SCOPE)
endfunction()

# Macro to find a package given platform-specific root paths
# Usage:
# zzpkg_find([PACKAGE_NAME/PACKAGE_VERSION] # Package name and version, required
#   WINDOWS  "path/to/windows/package"    # Package install path on Windows, optional
#   LINUX    "path/to/linux/package"      # Package install path on Linux, optional
#   ANDROID  "path/to/android/package"    # Package install path on Android, optional
#   MACOS    "path/to/macos/package"      # Package install path on macOS, optional
# )
macro(zzpkg_find PACKAGE_RECIPE)
  message(STATUS "Searching package with recipe: ${PACKAGE_RECIPE}")
  zzpkg_parse_recipe(${PACKAGE_RECIPE} pkg_name pkg_version pkg_hint)
  
  get_property(is_pkg_imported GLOBAL PROPERTY ${pkg_name}_imported)
  if(is_pkg_imported)
    get_property(imported_pkg_version GLOBAL PROPERTY ${pkg_name}_version)
    if(NOT ${imported_pkg_version} STREQUAL ${pkg_version})
      message(FATAL_ERROR "conflict version: imported(${imported_pkg_version}) vs to-be-imported(${pkg_version})")
    endif()
    get_property(imported_pkg_recipe GLOBAL PROPERTY ${pkg_name}_recipe)
    message(STATUS "  ${pkg_name} has been imported via recipe ${imported_pkg_recipe}, let's re-use it")
    set(pkg_recipe ${imported_pkg_recipe})
  else()
    set(pkg_recipe ${PACKAGE_RECIPE})
  endif()

  zzpkg_parse_recipe(${pkg_recipe} pkg_name pkg_version pkg_hint)
  message(STATUS "  acutal recipe: ${pkg_recipe}")
  message(STATUS "  pkg_name: ${pkg_name}")
  message(STATUS "  pkg_version: ${pkg_version}")
  message(STATUS "  pkg_hint: ${pkg_hint}")

  # parse major version
  string(REPLACE "." ";" pkg_version_parts "${pkg_version}")
  list(GET pkg_version_parts 0 pkg_version_major)
  message(STATUS "  pkg_version_major: ${pkg_version_major}")
  
  # 解析参数
  cmake_parse_arguments(
    ARG
    ""
    "WINDOWS;LINUX;ANDROID;MAC;DEFAULT"
    ""
    ${ARGN}
  )

  if((ZZPKG_PLATFORM STREQUAL "android") AND ARG_ANDROID)
    set(custom_pkg_root "${ARG_ANDROID}")
  elseif((ZZPKG_PLATFORM STREQUAL "windows") AND ARG_WINDOWS)
    set(custom_pkg_root "${ARG_WINDOWS}")
  elseif((ZZPKG_PLATFORM STREQUAL "mac") AND ARG_MAC)
    set(custom_pkg_root "${ARG_MAC}")
  elseif((ZZPKG_PLATFORM STREQUAL "linux") AND ARG_LINUX)
    set(custom_pkg_root "${ARG_LINUX}")
  elseif(ARG_DEFAULT)
    set(custom_pkg_root "${ARG_DEFAULT}")
  else()
    set(custom_pkg_root)
  endif()

  # 构建查找路径
  set(pkg_platform_independent_root "${ZZPKG_ROOT}/${pkg_name}/${pkg_version}")
  set(pkg_platform_dependent_root "${ZZPKG_ROOT}/${pkg_name}/${pkg_version}/${ZZPKG_PLATFORM}-${ZZPKG_ARCH}")
  set(pkg_platform_dependent_root_with_hint "${pkg_platform_dependent_root}")
  if(pkg_hint)
    STRING(APPEND pkg_platform_dependent_root_with_hint "-${pkg_hint}")
  endif()

  message(STATUS "  pkg_platform_independent_root: ${pkg_platform_independent_root}")
  message(STATUS "  pkg_platform_dependent_root: ${pkg_platform_dependent_root}")
  message(STATUS "  pkg_platform_dependent_root_with_hint: ${pkg_platform_dependent_root_with_hint}")

  if(NOT EXISTS ${pkg_platform_independent_root})
    message(FATAL_ERROR "pkg_platform_independent_root(${pkg_platform_independent_root}) does not exist for recipe: ${PACKAGE_RECIPE}")
  endif()

  set(candidate_pkg_root_list)
  if(custom_pkg_root)
    list(APPEND candidate_pk_root_list ${custom_pkg_root})
  endif()
  if(pkg_hint AND EXISTS ${pkg_platform_dependent_root_with_hint})
    list(APPEND candidate_pkg_root_list ${pkg_platform_dependent_root_with_hint})
  endif()
  list(APPEND candidate_pkg_root_list ${pkg_platform_dependent_root})
  list(APPEND candidate_pkg_root_list ${pkg_platform_independent_root})

  set(pkg_found FALSE)
  foreach(pkg_root ${candidate_pkg_root_list})
    if(pkg_found)
      break()
    endif()

    message(STATUS "  try find package with pkg_root: ${pkg_root}")
    if(EXISTS "${pkg_root}/inc")
      add_library(${pkg_name} INTERFACE)
      target_include_directories(${pkg_name} INTERFACE "${pkg_platform_independent_root}/inc")
      set_target_properties(${pkg_name} PROPERTIES
        VERSION ${pkg_version}
      )
      add_library(zzpkg::${pkg_name} ALIAS ${pkg_name})
      message(STATUS "  created INTERFACE target: zzpkg::${pkg_name}")
      set(pkg_found TRUE)
      break()
    endif()
      
    # 常见的 CMake config 文件位置
    set(candidate_subdirs
      ""
      cmake/lib # OpenCV Windows, OPENCV_CONFIG_INSTALL_PATH="cmake"
      cmake # OpenCV Linux, OPENCV_CONFIG_INSTALL_PATH="cmake"
      
      # ncnn, glfw
      lib/cmake/${pkg_name}
    )

    if(NOT(pkg_name MATCHES ".*[0-9]$"))
      list(APPEND candidate_subdirs
        # OpenCV, macOS/Linux, Default; glfw3 macOS, Default
        lib/cmake/${pkg_name}${pkg_version_major}
      )
    endif()

    # lib/cmake
    # lib
    # share/cmake/${pkg_name}
    # share/${pkg_name}

    if(ZZPKG_OS STREQUAL "windows")
      list(APPEND candidate_subdirs
        # OpenCV Windows, BUILD_SHARED_LIBS=ON, Default
        x64/vc18/bin
        x64/vc17/bin
        x64/vc16/bin
        x64/vc15/bin

        # OpenCV Windows, BUILD_SHARED_LIBS=OFF, OPENCV_CONFIG_INSTALL_PATH="cmake"
        cmake/staticlib
      )
    endif()

    if(ZZPKG_OS STREQUAL "android")
      list(APPEND candidate_subdirs
        # OpenCV Android, Default
        sdk/native/jni
        sdk/native/jni/abi-${ANDROID_ABI}
        # OpenCV Android, OPENCV_CONFIG_INSTALL_PATH="cmake"
        cmake/abi-${ANDROID_ABI}
      )
    endif()

    # 尝试查找 Config 文件
    set(candidate_targets ${pkg_name})
    # 判断 pkg_name 最后一个字符是否为数字, 如果不是数字，则添加 major 版本后缀的 target 名称
    if ((NOT pkg_name MATCHES ".*[0-9]$") AND (pkg_version_major MATCHES "^[0-9]+$"))
      list(APPEND candidate_targets "${pkg_name}${pkg_version_major}")
    endif()

    foreach(target ${candidate_targets})
      foreach(subdir ${candidate_subdirs})
        if(pkg_found)
          break()
        endif()
        set(config_path "${pkg_root}/${subdir}")
        set(config_files
          "${config_path}/${target}Config.cmake"
          "${config_path}/${target}-config.cmake"
        )
        foreach(config_file ${config_files})
          # message(STATUS "    Try config file: ${config_file}")
          if(EXISTS "${config_file}")
            set(${target}_DIR "${config_path}")
            message(STATUS "  find_package(${target}) with config file ${config_file}")
            find_package(${target} REQUIRED)
            set(pkg_found TRUE)
            break()
          endif()
        endforeach()
      endforeach()
    endforeach()
  endforeach()

  if(NOT pkg_found)
    message(FATAL_ERROR "Could not find ${PACKAGE_RECIPE} with ${pkg_recipe}")
  endif()
  
  # 设置全局导入标记
  set_property(GLOBAL PROPERTY ${pkg_name}_imported TRUE)
  set_property(GLOBAL PROPERTY ${pkg_name}_version "${pkg_version}")
  set_property(GLOBAL PROPERTY ${pkg_name}_recipe "${pkg_recipe}")  
  message(STATUS "  Successfully find ${pkg_recipe}")
  
  # clean up variables
  unset(pkg_recipe_parts)
  unset(pkg_recipe_parts_len)
  unset(pkg_name)
  unset(pkg_version)
  unset(pkg_hint)
  unset(pkg_version_parts)
  unset(pkg_version_major)
  unset(is_pkg_imported)
  unset(imported_pkg_version)
  unset(ARG_WINDOWS)
  unset(ARG_LINUX)
  unset(ARG_ANDROID)
  unset(ARG_MAC)
  unset(package_platform_independent_root)
  unset(package_platform_dependent_root)
  unset(package_platform_dependent_root_with_hint)
  unset(candidate_package_root_list)
  unset(custom_package_root)
  unset(package_found)
  unset(candidate_subdirs)
  unset(config_path)
  unset(config_files)
endmacro()


macro(zzpkg_change_output_directories)
  # Where add_executable() generates executable file
  # Where add_library(SHARED) generates .dll file on Windows
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out")

  # Where add_library(SHARED) generates shared library files (.so, .dylib)
  # Where add_library(MODULE) generates loadable module files (.dll, .so)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out")
  
  # Where add_library(STATIC) generates static library file
  # Where add_library(SHARED) generates the import library file (.lib) of the shared library (.dll) if exports at least one symbol
  # Where add_executable() generates the import library file (.lib) of the executable target if ENABLE_EXPORTS target property is set
  # Where add_executable() generates the linker import file (.imp on AIX) of the executable target if ENABLE_EXPORTS target property is set
  # Where add_library(SHARED) generates the linker import file (.tbd) of the shared library target if ENABLE_EXPORTS target property is set
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out")
  
  # For multi-config generators (e.g. MSBuild, XCode), the subdir `Debug`, `Release` is ugly, delete them
  if(GENERATOR_IS_MULTI_CONFIG)
    foreach(CONFIG_TYPE ${CMAKE_CONFIGURATION_TYPES})
      string(TOUPPER ${CONFIG_TYPE} CONFIG_TYPE_UPPER)
      set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} "${CMAKE_BINARY_DIR}/out")
      set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} "${CMAKE_BINARY_DIR}/out")
      set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} "${CMAKE_BINARY_DIR}/out")
    endforeach()
  endif()
endmacro()


macro(zzpkg_setup_for_msvc)
  if(MSVC)
    # Correctly print UTF-8 characters in MSVC output console
    add_compile_options("/source-charset:utf-8")

    # avoid MSVC compile error C2065: 'M_PI': undeclared identifier
    add_compile_definitions(_USE_MATH_DEFINES)
    
    # avoid MSVC compile warning C4996 when warning level /W3 or higher is used
    # - warning C4996: 'strcpy': This function or variable may be unsafe.
    # - warning C4996: 'fopen': This function or variable may be unsafe.
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)

    # avoid introduce macros that conflict with std::min and std::max
    # - error C2589: '(': illegal token on right side of '::'
    # - error C2059: syntax error: ')'
    add_compile_definitions(NOMINMAX)
    
    # to speedup the build process by excluding some less used APIs
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
  endif()
endmacro()


macro(zzpkg_enable_position_independent_code)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endmacro()


macro(zzpkg_export_compile_commands)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endmacro()


macro(zzpkg_setup_debug_postfix)
  if(GENERATOR_IS_MULTI_CONFIG)
    set(CMAKE_DEBUG_POSTFIX "_d")
  endif()
endmacro()


function(zzpkg_copy_dll TARGET)
  include(${ZZPKG_CMAKE_DIR}/igl_copy_dll.cmake)
  igl_copy_dll(${TARGET})
endfunction()

# Set default installation directory
macro(zzpkg_set_default_install_dir)
  if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "" FORCE)
  endif()
endmacro()


# Set default RPATH for installed binaries
macro(zzpkg_set_default_rpath)
  if(NOT CMAKE_INSTALL_RPATH)
    set(CMAKE_INSTALL_RPATH "$ORIGIN:$ORIGIN/../lib")
  endif()
endmacro()


# Global settings
zzpkg_set_root()
zzpkg_set_default_install_dir()
zzpkg_set_default_rpath()
zzpkg_detect_os()
zzpkg_detect_platform()
zzpkg_detect_arch()
zzpkg_enable_position_independent_code()
zzpkg_export_compile_commands()
zzpkg_change_output_directories()
zzpkg_setup_for_msvc()
zzpkg_setup_debug_postfix()