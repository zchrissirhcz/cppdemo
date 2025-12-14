zzpkg_find(ncnn
  WINDOWS "${ZZPKG_ROOT}/ncnn/master/vs2022-x64"
  LINUX   "${ZZPKG_ROOT}/ncnn/master/linux-x64"
  ANDROID "${ZZPKG_ROOT}/ncnn/master/android-arm64"
)

zzpkg_find(OpenCV
  WINDOWS  "${ZZPKG_ROOT}/opencv/4.12.0/vs2022-x64"
  LINUX    "${ZZPKG_ROOT}/opencv/4.12.0/linux-x64"
  ANDROID  "${ZZPKG_ROOT}/opencv/4.12.0/android-arm64"
)

add_executable(demo7 main.cpp)
target_link_libraries(demo7 PRIVATE ncnn ${OpenCV_LIBS})
igl_copy_dll(demo7)
