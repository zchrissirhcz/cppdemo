add_executable(demo1
  #test_comment.cpp
  #test_string.cpp
  #test_string2.cpp
  test_string3.cpp
)


zzpkg_find(fmt/12.1.0)
add_executable(test_unicode test_unicode.cpp)
target_link_libraries(test_unicode PRIVATE fmt::fmt)