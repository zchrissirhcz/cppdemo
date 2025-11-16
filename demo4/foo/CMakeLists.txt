add_library(foo SHARED
  foo.h
  foo.cpp
)
target_include_directories(foo PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
target_compile_definitions(foo PRIVATE FOO_EXPORTS)


install(FILES foo.h DESTINATION include/foo)
install(TARGETS foo
  EXPORT foo
  DESTINATION lib
  INCLUDES DESTINATION include
)
install(EXPORT foo
  DESTINATION cmake/foo
  FILE foo-config.cmake
)