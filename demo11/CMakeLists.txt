zzpkg_find(spdlog/1.16.0)
add_executable(demo11 main.cpp)
target_link_libraries(demo11 PRIVATE zzpkg::spdlog)