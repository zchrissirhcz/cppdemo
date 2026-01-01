set(CMAKE_CXX_STANDARD 11)

zzpkg_find(catch2/2.13.10)

add_executable(test_catch2 main.cpp)
target_link_libraries(test_catch2 PRIVATE zzpkg::catch2)
