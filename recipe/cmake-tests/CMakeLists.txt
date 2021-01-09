cmake_minimum_required(VERSION 3.8)

project(diana)

option(WITH_FINDCUDA "Find CUDA via find_package(CUDA)" ON)
option(WITH_FINDCUDATOOLKIT "Find CUDA via find_package(CUDAToolkit)" OFF)
option(WITH_ENABLE_LANGUAGE "Use enable_language(CUDA)" OFF)

file(GLOB cpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cc")
file(GLOB gpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cu")


if(WITH_ENABLE_LANGUAGE)
    # Modern CMake
    set(CMAKE_CUDA_STANDARD 17)
    set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
    enable_language(CUDA)
    if(WITH_FINDCUDA)
        find_package(CUDA REQUIRED)
    endif(WITH_FINDCUDA)
    if(WITH_FINDCUDATOOLKIT)
        find_package(CUDAToolkit REQUIRED)
    endif(WITH_FINDCUDA)
    add_executable(diana ${cpu_source_files} ${gpu_source_files})
else(WITH_ENABLE_LANGUAGE)
    # Old CMake
    add_executable(diana ${cpu_source_files})
    if(WITH_FINDCUDA)
        find_package(CUDA REQUIRED)
    endif(WITH_FINDCUDA)
    if(WITH_FINDCUDATOOLKIT)
        find_package(CUDAToolkit REQUIRED)
    endif(WITH_FINDCUDA)
    set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -std=c++17")
    CUDA_ADD_LIBRARY(diana_gpu ${gpu_source_files})
    target_link_libraries(diana diana_gpu)
endifWITH_ENABLE_LANGUAGE()

