add_subdirectory(foo)

add_executable(use_foo use_foo.cpp)
target_link_libraries(use_foo PRIVATE foo)