if(MSVC)
  # avoid MSVC compile error C2065: 'M_PI': undeclared identifier
  add_compile_definitions(_USE_MATH_DEFINES)
  
  # avoid MSVC compile warning C4996 when warning level /W3 or higher is used
  # - warning C4996: 'strcpy': This function or variable may be unsafe.
  # - warning C4996: 'fopen': This function or variable may be unsafe.
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS)

  # avoid introduce macros that conflict with std::min and std::max
  # - error C2589: '(': illegal token on right side of '::'
  # - error C2059: syntax error: ')'
  add_compile_definitions(NOMINMAX)
  
  # to speedup the build process by excluding some less used APIs
  add_compile_definitions(WIN32_LEAN_AND_MEAN)
endif()

add_executable(demo5 main.cpp)