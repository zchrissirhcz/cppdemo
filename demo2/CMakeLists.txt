zzpkg_find(ncnn/master)
add_executable(demo2 demo2.cpp)
target_link_libraries(demo2 PRIVATE ncnn)

# if(MSVC)
#   set_target_properties(
#     demo2 PROPERTIES
#     VS_DEBUGGER_ENVIRONMENT "PATH=${ZZPKG_ROOT}/ncnn/20250916/windows-vs2022-shared/x64/bin;%PATH%"
#   )
# endif()
zzpkg_copy_required_dlls(demo2)
