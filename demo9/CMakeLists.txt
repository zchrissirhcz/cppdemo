zzpkg_find(Eigen/3.4.0)
add_executable(eigen_test main.cpp)
target_link_libraries(eigen_test PRIVATE zzpkg::Eigen)
