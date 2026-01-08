add_executable(demo1
  #test_comment.cpp
  #test_string.cpp
  #test_string2.cpp
  #test_string3.cpp
  test_unicode.cpp
)
zzpkg_find(fmt/12.1.0)
target_link_libraries(demo1 PRIVATE fmt::fmt)
