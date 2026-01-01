zzpkg_find(OpenCV/4.12.0)
add_executable(demo3 demo3.cpp)
target_link_libraries(demo3 PRIVATE ${OpenCV_LIBS})

# if(MSVC)
#   set_target_properties(
#     demo3 PROPERTIES
#     VS_DEBUGGER_ENVIRONMENT "PATH=${ZZPKG_ROOT}/opencv/4.12.0/windows/x64/vc16/bin;%PATH%"
#   )
# endif()

#zzpkg_get_target_dependencies(demo3 DEMO3_DEPS)
#message(STATUS "DEMO3_DEPS: ${DEMO3_DEPS}")

#zzpkg_collect_target_dll_dirs(demo3 DEMO3_DLL_DIRS)
#message(STATUS "DEMO3_DLL_DIRS: ${DEMO3_DLL_DIRS}")

zzpkg_copy_required_dlls(demo3)
#zzpkg_generate_debug_env_files(demo3)