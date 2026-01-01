cmake_minimum_required(VERSION 3.15)
project(demo13 VERSION 1.0.0)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

zzpkg_find(glfw/3.4)

# 添加可执行文件
add_executable(${PROJECT_NAME} 
  main.cpp
)

# 链接 GLFW
target_link_libraries(${PROJECT_NAME} PRIVATE glfw)

# 包含目录
target_include_directories(${PROJECT_NAME} PRIVATE 
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# 平台特定设置
if(WIN32)
  target_link_libraries(${PROJECT_NAME} PRIVATE opengl32)
elseif(APPLE)
  add_compile_definitions(GL_SILENCE_DEPRECATION)
  find_library(COCOA_LIBRARY Cocoa REQUIRED)
  find_library(IOKIT_LIBRARY IOKit REQUIRED)
  find_library(COREVIDEO_LIBRARY CoreVideo REQUIRED)
  find_library(OPENGL_LIBRARY OpenGL REQUIRED)
  target_link_libraries(${PROJECT_NAME} PRIVATE 
    ${COCOA_LIBRARY}
    ${IOKIT_LIBRARY}
    ${COREVIDEO_LIBRARY}
    ${OPENGL_LIBRARY}
  )
elseif(UNIX)
  find_package(OpenGL REQUIRED)
  target_link_libraries(${PROJECT_NAME} PRIVATE OpenGL::GL)
endif()
