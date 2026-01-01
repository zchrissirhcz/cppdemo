zzpkg_find(cereal/1.3.2)

add_executable(test_cereal main.cpp)
target_link_libraries(test_cereal PRIVATE zzpkg::cereal)
