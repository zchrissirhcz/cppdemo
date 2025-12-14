zzpkg_find(OpenCV
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