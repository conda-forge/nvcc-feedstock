cmake_minimum_required(VERSION 3.8)

project(diana)

option(MODERN_CUDA "Find CUDA with modern approach" ON)

file(GLOB cpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cc")
file(GLOB gpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cu")


if(MODERN_CUDA)
    # Modern CMake
    set(CMAKE_CUDA_STANDARD 17)
    set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
    enable_language(CUDA)
    add_executable(diana ${cpu_source_files} ${gpu_source_files})
else()
    # Old CMake
    add_executable(diana ${cpu_source_files})
    find_package(CUDA REQUIRED)
    set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -std=c++17")
    CUDA_ADD_LIBRARY(diana_gpu ${gpu_source_files})
    target_link_libraries(diana diana_gpu)
endif()

