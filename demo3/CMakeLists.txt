function(find_opencv_smart)
  cmake_parse_arguments(
    ARG
    ""
    "WINDOWS;LINUX;ANDROID"
    ""
    ${ARGN}
  )

  # 根据平台选择路径
  if(ANDROID AND ARG_ANDROID)
    set(OpenCV_ROOT "${ARG_ANDROID}")
  elseif(WIN32 AND ARG_WINDOWS)
    set(OpenCV_ROOT "${ARG_WINDOWS}")
  elseif(UNIX AND NOT ANDROID AND ARG_LINUX)
    set(OpenCV_ROOT "${ARG_LINUX}")
  else()
    message(FATAL_ERROR "No OpenCV path provided for current platform")
  endif()

  set(candidate_subdirs
    # windows
    cmake/lib
    x64/vc18/lib
    x64/vc17/lib
    x64/vc16/lib
    x64/vc15/lib
    # linux
    cmake
    lib/cmake/opencv4
    lib/cmake/opencv
    # android
    sdk/native/jni/abi-${ANDROID_ABI}
    cmake/abi-${ANDROID_ABI}
  )

  foreach(subdir ${candidate_subdirs})
    if(EXISTS "${OpenCV_ROOT}/${subdir}/OpenCVConfig.cmake")
      set(OpenCV_DIR "${OpenCV_ROOT}/${subdir}" PARENT_SCOPE)
      message(STATUS "Found OpenCVConfig.cmake in: ${OpenCV_ROOT}/${subdir}")
      return()
    endif()
  endforeach()

  message(FATAL_ERROR "Could not find OpenCVConfig.cmake in subdirs of: ${OpenCV_ROOT}")
endfunction()

find_opencv_smart(
  WINDOWS  "${ZZPKG_ROOT}/opencv/4.12.0/vs2022-x64"
  LINUX    "${ZZPKG_ROOT}/opencv/4.12.0/linux-x64"
  ANDROID  "${ZZPKG_ROOT}/opencv/4.12.0/android-arm64"
)


add_executable(demo3 demo3.cpp)
target_link_libraries(demo3 PRIVATE ${OpenCV_LIBS})

# if(MSVC)
#   set_target_properties(
#     demo3 PROPERTIES
#     VS_DEBUGGER_ENVIRONMENT "PATH=${ZZPKG_ROOT}/opencv/4.12.0/windows/x64/vc16/bin;%PATH%"
#   )
# endif()
igl_copy_dll(demo3)