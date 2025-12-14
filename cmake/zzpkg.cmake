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

# Macro to find a package given platform-specific root paths
# Usage:
# zzpkg_find([PACKAGE_NAME]               # Package name, required
#   WINDOWS  "path/to/windows/package"    # Package install path on Windows, optional
#   LINUX    "path/to/linux/package"      # Package install path on Linux, optional
#   ANDROID  "path/to/android/package"    # Package install path on Android, optional
#   MACOS    "path/to/macos/package"      # Package install path on macOS, optional
#   COMPONENTS comp1 comp2 ...            # Required components, optional
#   OPTIONAL_COMPONENTS optcomp1 optcomp2 ... # Optional components, optional
# )
macro(zzpkg_find PACKAGE_NAME)
  cmake_parse_arguments(
    ARG
    ""
    "WINDOWS;LINUX;ANDROID;MACOS"
    "COMPONENTS;OPTIONAL_COMPONENTS"
    ${ARGN}
  )

  # 根据平台选择路径
  if(ANDROID AND ARG_ANDROID)
    set(package_root "${ARG_ANDROID}")
    set(platform_name "Android")
  elseif(WIN32 AND ARG_WINDOWS)
    set(package_root "${ARG_WINDOWS}")
    set(platform_name "Windows")
  elseif(APPLE AND ARG_MACOS)
    set(package_root "${ARG_MACOS}")
    set(platform_name "macOS")
  elseif(UNIX AND NOT ANDROID AND ARG_LINUX)
    set(package_root "${ARG_LINUX}")
    set(platform_name "Linux")
  else()
    message(FATAL_ERROR "No ${PACKAGE_NAME} path provided for current platform")
  endif()

  message(STATUS "Searching ${PACKAGE_NAME} on ${platform_name}")
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

  # 调用 find_package
  if(ARG_COMPONENTS)
    find_package(${PACKAGE_NAME} REQUIRED COMPONENTS ${ARG_COMPONENTS})
  elseif(ARG_OPTIONAL_COMPONENTS)
    find_package(${PACKAGE_NAME} REQUIRED OPTIONAL_COMPONENTS ${ARG_OPTIONAL_COMPONENTS})
  else()
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
  
endmacro()