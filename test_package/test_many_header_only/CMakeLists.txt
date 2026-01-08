set(CMAKE_CXX_STANDARD 11)

zzpkg_find(spdlog/1.16.0)
zzpkg_find(fmt/12.1.0)
zzpkg_find(ghc-filesystem/1.5.14)
zzpkg_find(CLI11/2.6.1)
add_compile_definitions(SPDLOG_FMT_EXTERNAL_HO)

add_executable(test_many_header_only main.cpp)
target_link_libraries(test_many_header_only PRIVATE zzpkg::spdlog fmt::fmt zzpkg::ghc-filesystem zzpkg::CLI11)