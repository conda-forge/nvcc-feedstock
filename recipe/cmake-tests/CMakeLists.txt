cmake_minimum_required(VERSION 3.17)

project(diana)

option(CUDA_FINDER "Which method find_package will use: CUDA or CUDAToolkit" "CUDA")
option(WITH_ENABLE_LANGUAGE "Use enable_language(CUDA)" OFF)
message(STATUS "WITH_ENABLE_LANGUAGE=${WITH_ENABLE_LANGUAGE} CUDA_FINDER=${CUDA_FINDER}")

set(VALID_CUDA_FINDERS "CUDA" "CUDAToolkit")
if(NOT ${CUDA_FINDER} IN_LIST VALID_CUDA_FINDERS)
    message(FATAL_ERROR "CUDA_FINDER must be one of: ${VALID_CUDA_FINDERS}")
endif()

file(GLOB cpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cc")
file(GLOB gpu_source_files "${CMAKE_SOURCE_DIR}/src/*.cu")
file(GLOB include_files "${CMAKE_SOURCE_DIR}/src/*.hpp")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

if(WITH_ENABLE_LANGUAGE)
    enable_language(CUDA)
    set(CMAKE_CUDA_STANDARD 14)
    set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
    find_package("${CUDA_FINDER}" REQUIRED)
    add_executable(diana ${cpu_source_files} ${gpu_source_files})

else(WITH_ENABLE_LANGUAGE)
    add_executable(diana ${cpu_source_files})

    if("${CUDA_FINDER}" STREQUAL "CUDA")
        message(STATUS "With CUDA")
        find_package("${CUDA_FINDER}" REQUIRED)
        set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -Xcompiler ,\"-std=c++14\"")
        CUDA_ADD_LIBRARY(diana_gpu ${gpu_source_files})
    else("${CUDA_FINDER}" STREQUAL "CUDA")
        find_package("${CUDA_FINDER}" REQUIRED)
        add_library(diana_gpu ${gpu_source_files})
        set_target_properties(diana_gpu PROPERTIES LINKER_LANGUAGE "CXX")
    endif("${CUDA_FINDER}" STREQUAL "CUDA")

    target_link_libraries(diana diana_gpu)

endif(WITH_ENABLE_LANGUAGE)
