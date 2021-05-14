#!/bin/bash


# Restore environment variables (if there is anything to restore)
if [[ ! -z "\${CUDA_HOME_CONDA_NVCC_BACKUP+x}" ]]
then
  export CUDA_HOME="\${CUDA_HOME_CONDA_NVCC_BACKUP}"
  unset CUDA_HOME_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CUDA_PATH_CONDA_NVCC_BACKUP+x}" ]]
then
  export CUDA_PATH="\${CUDA_PATH_CONDA_NVCC_BACKUP}"
  unset CUDA_PATH_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CFLAGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CFLAGS="\${CFLAGS_CONDA_NVCC_BACKUP}"
  unset CFLAGS_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CPPFLAGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CPPFLAGS="\${CPPFLAGS_CONDA_NVCC_BACKUP}"
  unset CPPFLAGS_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CXXFLAGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CXXFLAGS="\${CXXFLAGS_CONDA_NVCC_BACKUP}"
  unset CXXFLAGS_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CMAKE_ARGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CMAKE_ARGS="\${CMAKE_ARGS_CONDA_NVCC_BACKUP}"
  unset CMAKE_ARGS_CONDA_NVCC_BACKUP
fi

# Remove or restore \$(libcuda.so) shared object stub from the compiler sysroot.
LIBCUDA_SO_CONDA_NVCC_BACKUP="\${CONDA_BUILD_SYSROOT}/lib/libcuda.so-conda-nvcc-backup"
if [[ -f ""\${LIBCUDA_SO_CONDA_NVCC_BACKUP}"" ]]
then
  mv -f "\${LIBCUDA_SO_CONDA_NVCC_BACKUP}" "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so"
else
  rm -f "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so"
fi
