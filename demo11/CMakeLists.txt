zzpkg_find(spdlog/1.16.0)
zzpkg_find(fmt/12.1.0)
add_compile_definitions(SPDLOG_FMT_EXTERNAL_HO)

add_executable(demo11 main.cpp)
target_link_libraries(demo11 PRIVATE zzpkg::spdlog zzpkg::fmt)