zzpkg_find(cereal/1.3.2)

add_executable(demo10 main.cpp)
target_link_libraries(demo10 PRIVATE zzpkg::cereal)
