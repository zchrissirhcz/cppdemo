zzpkg_find(pystring/1.1.4:static)

add_executable(test_pystring main.cpp)
target_link_libraries(test_pystring PRIVATE pystring::pystring)