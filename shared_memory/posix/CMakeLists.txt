cmake_minimum_required(VERSION 3.10)
project(shared_memory_posix)

add_executable(writer writer.cpp)
add_executable(reader reader.cpp)

# Link with rt library for shm_open/shm_unlink
target_link_libraries(writer rt)
target_link_libraries(reader rt)
