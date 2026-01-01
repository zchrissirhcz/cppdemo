zzpkg_find(Eigen/3.4.0)
add_executable(test_eigen main.cpp)
target_link_libraries(test_eigen PRIVATE zzpkg::Eigen)
