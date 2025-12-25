set(CMAKE_CXX_STANDARD 11)

zzpkg_find(catch2/2.13.10)

add_executable(demo12 main.cpp)
target_link_libraries(demo12 PRIVATE zzpkg::catch2)
