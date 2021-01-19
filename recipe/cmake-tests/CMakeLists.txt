cmake_minimum_required(VERSION 3.17)

project(diana)

option(CUDA_FINDER "Which method find_package will use: CUDA or CUDAToolkit" "CUDA")
option(WITH_ENABLE_LANGUAGE "Use enable_language(CUDA)" OFF)
message(STATUS "WITH_ENABLE_LANGUAGE=${WITH_ENABLE_LANGUAGE} CUDA_FINDER=${CUDA_FINDER}")

set(VALID_CUDA_FINDERS "CUDA" "CUDAToolkit" "OFF")
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
    if(CUDA_FINDER)
        find_package("${CUDA_FINDER}" REQUIRED)
    endif(CUDA_FINDER)
    add_definitions("-DWITHCUFILES")
    add_executable(diana ${cpu_source_files} ${gpu_source_files})

else(WITH_ENABLE_LANGUAGE)
    add_executable(diana ${cpu_source_files})

    if("${CUDA_FINDER}" STREQUAL "CUDA")
        find_package("${CUDA_FINDER}" REQUIRED)
        set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -Xcompiler ,\"-std=c++14\"")
        add_definitions("-DWITHCUFILES")
        CUDA_ADD_LIBRARY(diana_gpu ${gpu_source_files})
        target_link_libraries(diana diana_gpu)
    elseif("${CUDA_FINDER}" STREQUAL "CUDAToolkit")
        # This example does not link to .cu libraries
        find_package("${CUDA_FINDER}" REQUIRED)
        target_link_libraries(diana CUDA::cudart)
    endif("${CUDA_FINDER}" STREQUAL "CUDA")


endif(WITH_ENABLE_LANGUAGE)


# Some more checks
if(WIN32)
    set(NVCC_WRAPPER "$ENV{PREFIX}/Library/bin/nvcc.bat")
else(WIN32)
    set(NVCC_WRAPPER "$ENV{PREFIX}/bin/nvcc")
endif(WIN32)

if(CUDA_FINDER)
    if("${CUDA_FINDER}" STREQUAL "CUDA")
        set(FOUND_NVCC "${CMAKE_CUDA_COMPILER}")
    elseif("${CUDA_FINDER}" STREQUAL "CUDAToolkit")
        set(FOUND_NVCC "${CUDAToolkit_NVCC_EXECUTABLE}")
    endif("${CUDA_FINDER}" STREQUAL "CUDA")

    if("${FOUND_NVCC}" STREQUAL "${NVCC_WRAPPER}")
        message(STATUS "NVCC found at ${NVCC_WRAPPER}")
    else("${FOUND_NVCC}" STREQUAL "${NVCC_WRAPPER}")
        message(FATAL_ERROR "NVCC found (${FOUND_NVCC}) is NOT ${NVCC_WRAPPER}!")
    endif("${FOUND_NVCC}" STREQUAL "${NVCC_WRAPPER}")
endif(CUDA_FINDER)

if(WITH_ENABLE_LANGUAGE)
    if("${CMAKE_CUDA_COMPILER}" STREQUAL "${NVCC_WRAPPER}")
        message(STATUS "CMAKE_CUDA_COMPILER matches ${NVCC_WRAPPER}")
    else("${CMAKE_CUDA_COMPILER}" STREQUAL "${NVCC_WRAPPER}")
        message(FATAL_ERROR "CMAKE_CUDA_COMPILER (${CMAKE_CUDA_COMPILER}) does NOT match ${NVCC_WRAPPER}!")
    endif("${CMAKE_CUDA_COMPILER}" STREQUAL "${NVCC_WRAPPER}")
endif(WITH_ENABLE_LANGUAGE)
