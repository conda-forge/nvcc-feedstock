cmake_minimum_required(VERSION 3.17)

project(diana)

option(WITH_FINDCUDA "Find CUDA via find_package(CUDA)" ON)
option(WITH_FINDCUDATOOLKIT "Find CUDA via find_package(CUDAToolkit)" OFF)
option(WITH_ENABLE_LANGUAGE "Use enable_language(CUDA)" OFF)

file(GLOB cpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cc")
file(GLOB gpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cu")
file(GLOB include_files "${CMAKE_SOURCE_DIR}/src/*.hpp")

message(STATUS "WITH_FINDCUDA=${WITH_FINDCUDA} WITH_FINDCUDATOOLKIT=${WITH_FINDCUDATOOLKIT} WITH_ENABLE_LANGUAGE=${WITH_ENABLE_LANGUAGE}")

if(WITH_ENABLE_LANGUAGE)
    set(CMAKE_CUDA_STANDARD 17)
    set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
    enable_language(CUDA)

    if(WITH_FINDCUDA)
        find_package(CUDA REQUIRED)
    endif(WITH_FINDCUDA)

    if(WITH_FINDCUDATOOLKIT)
        find_package(CUDAToolkit REQUIRED)
    endif(WITH_FINDCUDATOOLKIT)

    add_executable(diana ${cpu_source_files} ${gpu_source_files})

else(WITH_ENABLE_LANGUAGE)
    add_executable(diana ${cpu_source_files})

    if(WITH_FINDCUDA)
        find_package(CUDA REQUIRED)
        if(CUDA_VERSION_MAJOR GREATER_EQUAL 11)
            set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -std=c++17")
        endif(CUDA_VERSION_MAJOR GREATER_EQUAL 11)
        CUDA_ADD_LIBRARY(diana_gpu ${gpu_source_files})
    endif(WITH_FINDCUDA)

    if(WITH_FINDCUDATOOLKIT)
        find_package(CUDAToolkit REQUIRED)
        add_library(diana_gpu ${gpu_source_files})
        set_target_properties(diana_gpu PROPERTIES LINKER_LANGUAGE "CXX")
    endif(WITH_FINDCUDATOOLKIT)

    target_link_libraries(diana diana_gpu)

endif(WITH_ENABLE_LANGUAGE)
