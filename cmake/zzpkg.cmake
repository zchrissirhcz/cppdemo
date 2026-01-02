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
        x64/vc18/lib
        x64/vc17/lib
        x64/vc16/lib
        x64/vc15/lib

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
  get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
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
  get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(GENERATOR_IS_MULTI_CONFIG)
    set(CMAKE_DEBUG_POSTFIX "_d")
  endif()
endmacro()


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


# function(zzpkg_get_target_dependencies TARGET OUTPUT_VAR)
#   set(visited "")
#   set(to_process "${TARGET}")
#   set(all_deps "")
#   while(to_process)
#     list(GET to_process 0 current)
#     list(REMOVE_AT to_process 0)

#     list(FIND visited "${current}" found)
#     if(NOT (found EQUAL -1))
#       continue()
#     endif()

#     list(APPEND visited "${current}")
#     if(NOT TARGET ${current})
#       continue()
#     endif()

#     foreach(property LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
#       get_target_property(deps ${current} ${property})
#       if(deps)
#         foreach(dep ${deps})
#           list(APPEND to_process "${dep}")
#           list(APPEND all_deps "${dep}")
#         endforeach()
#       endif()
#     endforeach()
#   endwhile()

#   if(all_deps)
#     list(REMOVE_DUPLICATES all_deps)
#   endif()

#   set(${OUTPUT_VAR} "${all_deps}" PARENT_SCOPE)
# endfunction()


# Transitively list all link libraries of a target (recursive call)
# Modified from https://github.com/libigl/libigl/blob/main/cmake/igl/igl_copy_dll.cmake, GPL-3.0 / MPL-2.0
function(zzpkg_get_target_dependencies_impl OUTPUT_VARIABLE TARGET)
  get_target_property(_aliased ${TARGET} ALIASED_TARGET)
  if(_aliased)
    set(TARGET ${_aliased})
  endif()

  get_target_property(_IMPORTED ${TARGET} IMPORTED)
  get_target_property(_TYPE ${TARGET} TYPE)
  if(_IMPORTED OR (${_TYPE} STREQUAL "INTERFACE_LIBRARY"))
    get_target_property(TARGET_DEPENDENCIES ${TARGET} INTERFACE_LINK_LIBRARIES)
  else()
    get_target_property(TARGET_DEPENDENCIES ${TARGET} LINK_LIBRARIES)
  endif()

  set(VISITED_TARGETS ${${OUTPUT_VARIABLE}})
  foreach(DEPENDENCY IN ITEMS ${TARGET_DEPENDENCIES})
    if(TARGET ${DEPENDENCY})
      get_target_property(_aliased ${DEPENDENCY} ALIASED_TARGET)
      if(_aliased)
        set(DEPENDENCY ${_aliased})
      endif()

      if(NOT (DEPENDENCY IN_LIST VISITED_TARGETS))
        list(APPEND VISITED_TARGETS ${DEPENDENCY})
        zzpkg_get_target_dependencies_impl(VISITED_TARGETS ${DEPENDENCY})
      endif()
    endif()
  endforeach()
  set(${OUTPUT_VARIABLE} ${VISITED_TARGETS} PARENT_SCOPE)
endfunction()


# Transitively list all link libraries of a target
function(zzpkg_get_target_dependencies OUTPUT_VARIABLE TARGET)
  set(DISCOVERED_TARGETS "")
  zzpkg_get_target_dependencies_impl(DISCOVERED_TARGETS ${TARGET})
  set(${OUTPUT_VARIABLE} ${DISCOVERED_TARGETS} PARENT_SCOPE)
endfunction()


function(zzpkg_collect_target_dll_dirs TARGET OUTPUT_VAR)
  if(NOT MSVC)
    return()
  endif()
  zzpkg_get_target_dependencies(${TARGET} deps)
  set(dll_dirs "")  
  foreach(d ${deps})
    if(NOT TARGET ${d})
      continue()
    endif()
    # only consider shared library
    get_target_property(d_type ${d} TYPE)
    if(NOT d_type STREQUAL "SHARED_LIBRARY")
      continue()
    endif()    
    get_target_property(d_is_imported ${d} IMPORTED)    
    if(d_is_imported)
      get_target_property(d_imported_location ${d} IMPORTED_LOCATION)
      if(d_imported_location)
        get_filename_component(d_imported_dir "${d_imported_location}" DIRECTORY)
        list(APPEND dll_dirs "${d_imported_dir}")
      endif()            
      foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
        get_target_property(d_imported_loc ${d} IMPORTED_LOCATION_${config})
        if(d_imported_loc)
          get_filename_component(d_imported_dir "${d_imported_loc}" DIRECTORY)
          list(APPEND dll_dirs "${d_imported_dir}")
        endif()
      endforeach()
    else()
      get_target_property(d_runtime_dir ${d} RUNTIME_OUTPUT_DIRECTORY)
      if(d_runtime_dir)
        list(APPEND dll_dirs "${d_runtime_dir}")
      else()
        get_target_property(d_binary_dir ${d} BINARY_DIR)
        if(d_binary_dir)
          list(APPEND dll_dirs "${d_binary_dir}")
        endif()
      endif()            
      foreach(config Debug Release RelWithDebInfo MinSizeRel)
        string(TOUPPER ${config} config_upper)
        get_target_property(config_dir ${TARGET} RUNTIME_OUTPUT_DIRECTORY_${config_upper})
        if(config_dir)
          list(APPEND dll_dirs "${config_dir}")
        endif()
      endforeach()
    endif()
  endforeach()

  if(dll_dirs)
    list(REMOVE_DUPLICATES dll_dirs)
  endif()
    
  set(${OUTPUT_VAR} "${dll_dirs}" PARENT_SCOPE)
endfunction()


macro(zzpkg_early_return_if_not_msvc_exe TARGET)
  if(NOT MSVC)
    return()
  endif()
  if(NOT TARGET ${TARGET})
    return()
  endif()
  get_target_property(TYPE ${TARGET} TYPE)
  if(NOT ${TYPE} STREQUAL "EXECUTABLE")
    return()
  endif()
endmacro()


function(zzpkg_get_required_dlls TARGET OUTPUT_VAR)
  zzpkg_early_return_if_not_msvc_exe(${TARGET})

  # Sanity checks
  if(CMAKE_CROSSCOMPILING OR (NOT WIN32))
    return()
  endif()

  if(NOT TARGET ${TARGET})
    message(STATUS "zzpkg_get_required_dlls() was called with a non-target: ${TARGET}")
    return()
  endif()

  # Sanity checks
  get_target_property(TYPE ${TARGET} TYPE)
  if(NOT ${TYPE} STREQUAL "EXECUTABLE")
    message(FATAL_ERROR "zzpkg_get_required_dlls() was called on a non-executable target: ${TARGET}")
  endif()

  # Retrieve all target dependencies
  zzpkg_get_target_dependencies(TARGET_DEPENDENCIES ${TARGET})

  set(required_dlls)
  foreach(DEPENDENCY IN LISTS TARGET_DEPENDENCIES)
    get_target_property(TYPE ${DEPENDENCY} TYPE)
    if(NOT (${TYPE} MATCHES "^(SHARED_LIBRARY|MODULE_LIBRARY|STATIC_LIBRARY)"))
      continue()
    endif()
    get_target_property(IMPORTED ${DEPENDENCY} IMPORTED)
    if(IMPORTED)
      # get where the imported dll is located
      get_target_property(IMPORT_LOCATION ${DEPENDENCY} IMPORTED_LOCATION)
      if(NOT IMPORT_LOCATION)
        get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
        if(GENERATOR_IS_MULTI_CONFIG)
          foreach(CONFIG_TYPE ${CMAKE_CONFIGURATION_TYPES})
            string(TOUPPER ${CONFIG_TYPE} CONFIG_TYPE_UPPER)
            get_target_property(IMPORT_LOCATION ${DEPENDENCY} IMPORTED_LOCATION_${CONFIG_TYPE_UPPER})
            if(IMPORT_LOCATION)
              break()
            endif()
          endforeach()
        endif()
      endif()
      if(NOT IMPORT_LOCATION)
        continue()
      endif()
      
      if(${TYPE} MATCHES "^(SHARED_LIBRARY|MODULE_LIBRARY)$")
        list(APPEND required_dlls "${IMPORT_LOCATION}")
      endif()
      
      # scan extra dll files in same dir
      get_filename_component(IMPORT_DIR "${IMPORT_LOCATION}" DIRECTORY)
      file(GLOB EXTRA_DLLS "${IMPORT_DIR}/*.dll")
      foreach(extra_dll IN LISTS EXTRA_DLLS)
        if(extra_dll STREQUAL IMPORT_LOCATION)
          continue()
        endif()
        set(should_add TRUE)
        foreach(x d _d)
          # remove postfix of extra_dll
          string(REGEX REPLACE "\\.dll$" "" extra_dll_base "${extra_dll}")
          string(REGEX REPLACE "\\.dll$" "" import_location_base "${IMPORT_LOCATION}")
          if("${extra_dll_base}${x}" STREQUAL "${import_location_base}")
            set(should_add FALSE)
            continue()
          endif()
          if("${extra_dll_base}" STREQUAL "${import_location_base}${x}")
            set(should_add FALSE)
            continue()
          endif()
        endforeach()
        if(should_add)
          list(APPEND required_dlls "${extra_dll}")
        endif()
      endforeach()

      # scan extra dll files in ../bin
      get_filename_component(IMPORTED_DIR "${IMPORT_LOCATION}" DIRECTORY)
      get_filename_component(last_dir "${IMPORTED_DIR}" NAME)
      if(last_dir STREQUAL "lib")
        get_filename_component(parent_dir "${IMPORTED_DIR}" DIRECTORY)
        set(bin_dir "${parent_dir}/bin")
        if(EXISTS "${bin_dir}" AND IS_DIRECTORY "${bin_dir}")
          file(GLOB EXTRA_DLLS "${bin_dir}/*.dll")
          foreach(dll IN LISTS EXTRA_DLLS)
            list(APPEND required_dlls "${dll}")
          endforeach()
        endif()
      endif()
    endif()
  endforeach()

  list(REMOVE_DUPLICATES required_dlls)
  set(${OUTPUT_VAR} "${required_dlls}" PARENT_SCOPE)
endfunction()


# Generate (configure stage) and run script (post build) to copy required DLLs to target output directory
# Without this, launching or debugging the executable in VSCode may fail with error 0xC0000135
#
# Usage:
#   in CMakeLists.txt:
#     zzpkg_copy_required_dlls(<target>)
function(zzpkg_copy_required_dlls TARGET)
  zzpkg_early_return_if_not_msvc_exe(${TARGET})

  zzpkg_get_required_dlls(${TARGET} REQUIRED_DLLS)

  # set the name of file to be written
  set(COPY_DLLS_SCRIPT_DIR "${CMAKE_BINARY_DIR}/zzpkg_copy_required_dlls")
  file(MAKE_DIRECTORY "${COPY_DLLS_SCRIPT_DIR}")
  if(DEFINED CMAKE_CONFIGURATION_TYPES)
    set(COPY_SCRIPT "${COPY_DLLS_SCRIPT_DIR}/${TARGET}_$<CONFIG>.cmake")
  else()
    set(COPY_SCRIPT "${COPY_DLLS_SCRIPT_DIR}/${TARGET}.cmake")
  endif()

  add_custom_command(
    TARGET ${TARGET}
    PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E touch "${COPY_SCRIPT}"
    COMMAND ${CMAKE_COMMAND} -P "${COPY_SCRIPT}"
    COMMENT "Copying dlls for target ${TARGET}"
  )

  string(REPLACE ";" "\n" REQUIRED_DLLS_STR "${REQUIRED_DLLS}")

  set(COPY_SCRIPT_CONTENT "")
  string(APPEND COPY_SCRIPT_CONTENT
    "set(required_dlls \n${REQUIRED_DLLS_STR}\n)\n\n"
    #"list(REMOVE_DUPLICATES required_dlls)\n\n"
    "foreach(dll IN ITEMS \${required_dlls})\n"
    "  if(EXISTS \"\${dll}\")\n    "
        "execute_process(COMMAND \${CMAKE_COMMAND} -E copy_if_different "
        "\"\${dll}\" \"$<TARGET_FILE_DIR:${TARGET}>/\")\n"
    "  endif()\n"
  )
  string(APPEND COPY_SCRIPT_CONTENT "endforeach()\n")

  # Finally generate one script for each configuration supported by this generator
  message(STATUS "Populating copy rules for target: ${TARGET} via script: ${COPY_SCRIPT}")
  file(GENERATE
    OUTPUT "${COPY_SCRIPT}"
    CONTENT "${COPY_SCRIPT_CONTENT}"
  )
endfunction()


# Generate envFile for running/debugging executable in VSCode
# This envFile will set PATH to include directories of required DLLs
# Without this, launching or debugging the executable in VSCode may fail with error 0xC0000135
# Support MSBuild and Ninja generators
#
# Usage:
#   in CMakeLists.txt:
#     zzpkg_generate_debug_envfile(<target>)
#   in .vscode/launch.json:
#     {
#       "name": "Launch Program",
#       "type": "cppvsdbg",
#       "request": "launch",
#       "program": "${workspaceFolder}/out/<target>.exe",
#       "args": [],
#       "stopAtEntry": false,
#       "cwd": "${workspaceFolder}",
#       "environment": [],
#       "externalConsole": false,
#       "envFile": "${workspaceFolder}/out/<target>_Debug.env"
#     }
function(zzpkg_generate_debug_envfile TARGET)
  zzpkg_early_return_if_not_msvc_exe(${TARGET})

  zzpkg_get_required_dlls(${TARGET} REQUIRED_DLLS)

  set(DLL_DIRS "")
  foreach(dll ${REQUIRED_DLLS})
    # get directory of dll
    get_filename_component(dll_dir "${dll}" DIRECTORY)
    list(APPEND DLL_DIRS "${dll_dir}")
  endforeach()
  list(REMOVE_DUPLICATES DLL_DIRS)
  set(NEW_PATH_STR "PATH=${DLL_DIRS};%PATH%")

  set(DEBUG_ENV_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
  #set(DEBUG_ENV_DIR "${CMAKE_SOURCE_DIR}/.vscode")
  if(DEFINED CMAKE_CONFIGURATION_TYPES)
    set(DEBUG_ENV_SCRIPT "${DEBUG_ENV_DIR}/${TARGET}_$<CONFIG>.env")
  else()
    set(DEBUG_ENV_SCRIPT "${DEBUG_ENV_DIR}/${TARGET}_${CMAKE_BUILD_TYPE}.env")
  endif()
  file(MAKE_DIRECTORY "${DEBUG_ENV_DIR}")
  string(APPEND DEBUG_ENV_CONTENT "${NEW_PATH_STR}\n")
  file(GENERATE
    OUTPUT "${DEBUG_ENV_SCRIPT}"
    CONTENT "${DEBUG_ENV_CONTENT}"
  )
endfunction()


# Set VS_DEBUGGER_ENVIRONMENT property for executable target in Visual Studio
# This will set environment variables for debugger in Visual Studio IDE
# Without this, launching or debugging the executable in VSCode may fail with error 0xC0000135
#
# Usage:
#   in CMakeLists.txt:
#     zzpkg_set_vs_debugger_environment(<target>)
#
# References:
# - https://cmake.org/cmake/help/latest/prop_tgt/VS_DEBUGGER_ENVIRONMENT.html
function(zzpkg_set_vs_debugger_environment TARGET)
  # skip non-MSVC generators
  if(NOT (CMAKE_GENERATOR MATCHES "Visual Studio"))
    return()
  endif()

  # skip non-executable targets
  get_target_property(TARGET_TYPE ${TARGET} TYPE)
  if(NOT TARGET_TYPE STREQUAL "EXECUTABLE")
    return()
  endif()

  # handle asan related environment variables
  set(VC_DIR)
  set(ASAN_SYMBOLIZER_PATH)
  set(HAS_ASAN FALSE)
  if(CMAKE_C_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # Check if TARGET is with ASAN enabled
    get_target_property(TARGET_COMPILE_OPTIONS ${TARGET} COMPILE_OPTIONS)
    message(STATUS "TARGET_COMPILE_OPTIONS for target ${TARGET}: ${TARGET_COMPILE_OPTIONS}")
    if(TARGET_COMPILE_OPTIONS MATCHES "/fsanitize=address")
      set(HAS_ASAN TRUE)
      # https://devblogs.microsoft.com/cppblog/msvc-address-sanitizer-one-dll-for-all-runtime-configurations/
      if((CMAKE_C_COMPILER_VERSION STRGREATER_EQUAL 17.7) OR (CMAKE_CXX_COMPILER_VERSION STRGREATER_EQUAL 17.7))
        if((CMAKE_GENERATOR_PLATFORM MATCHES "x64") OR ((CMAKE_SIZEOF_VOID_P EQUAL 8) AND (CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")))
          set(VC_DIR "$(VC_ExecutablePath_x64)")
          set(ASAN_SYMBOLIZER_PATH "$(VC_ExecutablePath_x64)")
        elseif((CMAKE_GENERATOR_PLATFORM MATCHES "Win32") OR ((CMAKE_SIZEOF_VOID_P EQUAL 4) AND (CMAKE_SYSTEM_PROCESSOR STREQUAL "^(x86|AMD64)$")))
          set(VC_DIR "$(VC_ExecutablePath_x86)")
          set(ASAN_SYMBOLIZER_PATH "$(VC_ExecutablePath_x86)")
        endif()
      endif()
    endif()
  endif()

  # collect directories of required dlls, save them in EXTRA_DIRS
  zzpkg_get_required_dlls(${TARGET} REQUIRED_DLLS)
  set(DLL_DIRS)
  foreach(dll ${REQUIRED_DLLS})
    # get directory of dll
    get_filename_component(dll_dir "${dll}" DIRECTORY)
    list(APPEND DLL_DIRS "${dll_dir}")
  endforeach()
  list(REMOVE_DUPLICATES DLL_DIRS)

  if(HAS_ASAN)
    if(DLL_DIRS)
      set(VS_DEBUGGER_ENVIRONMENT "PATH=${DLL_DIRS};${VC_DIR};%PATH%\nASAN_SYMBOLIZER_PATH=${ASAN_SYMBOLIZER_PATH}")
    else()
      set(VS_DEBUGGER_ENVIRONMENT "PATH=${VC_DIR};%PATH%\nASAN_SYMBOLIZER_PATH=${ASAN_SYMBOLIZER_PATH}")
    endif()
  else()
    if(DLL_DIRS)
      set(VS_DEBUGGER_ENVIRONMENT "PATH=${DLL_DIRS};%PATH%")
    endif()
  endif()

  get_target_property(old_vs_debugger_environment ${TARGET} VS_DEBUGGER_ENVIRONMENT)
  if(${old_vs_debugger_environment})
    message(FATAL_ERROR "existing VS_DEBUGGER_ENVIRONMENT found for target ${TARGET}, please resolve the conflict")
  endif()

  # set the VS_DEBUGGER_ENVIRONMENT property
  if(VS_DEBUGGER_ENVIRONMENT)
    set_target_properties(
      ${TARGET} PROPERTIES
      VS_DEBUGGER_ENVIRONMENT "${VS_DEBUGGER_ENVIRONMENT}"
    )
    message(STATUS "Set VS_DEBUGGER_ENVIRONMENT for target ${TARGET}:\n${VS_DEBUGGER_ENVIRONMENT}")
  endif()
endfunction()


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