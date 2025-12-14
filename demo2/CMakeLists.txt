zzpkg_find(ncnn
  WINDOWS "${ZZPKG_ROOT}/ncnn/master/vs2022-x64"
  LINUX   "${ZZPKG_ROOT}/ncnn/master/linux-x64"
  ANDROID "${ZZPKG_ROOT}/ncnn/master/android-arm64"
)

add_executable(demo2 demo2.cpp)
target_link_libraries(demo2 PRIVATE ncnn)

# if(MSVC)
#   set_target_properties(
#     demo2 PROPERTIES
#     VS_DEBUGGER_ENVIRONMENT "PATH=${ZZPKG_ROOT}/ncnn/20250916/windows-vs2022-shared/x64/bin;%PATH%"
#   )
# endif()
igl_copy_dll(demo2)