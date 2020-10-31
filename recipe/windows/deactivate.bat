:: Restore environment variables (if there is anything to restore)
if not "%CUDA_HOME_CONDA_NVCC_BACKUP%"=="" (
  set "CUDA_HOME=%CUDA_HOME_CONDA_NVCC_BACKUP%"
  set "CUDA_HOME_CONDA_NVCC_BACKUP="
)

if not "%CUDA_PATH_CONDA_NVCC_BACKUP%"=="" (
  set "CUDA_PATH=%CUDA_PATH_CONDA_NVCC_BACKUP%"
  set "CUDA_PATH_CONDA_NVCC_BACKUP="
)

if not "%CFLAGS_CONDA_NVCC_BACKUP%"=="" (
  set "CFLAGS=%CFLAGS_CONDA_NVCC_BACKUP%"
  set "CFLAGS_CONDA_NVCC_BACKUP="
)

if not "%CPPFLAGS_CONDA_NVCC_BACKUP%"=="" (
  set "CPPFLAGS=%CPPFLAGS_CONDA_NVCC_BACKUP%"
  set "CPPFLAGS_CONDA_NVCC_BACKUP="
)

if not "%CXXFLAGS_CONDA_NVCC_BACKUP%"=="" (
  set "CXXFLAGS=%CXXFLAGS_CONDA_NVCC_BACKUP%"
  set "CXXFLAGS_CONDA_NVCC_BACKUP="
)

:: JRG: Should CONDA_BUILD_SYSROOT be replaced with LIBRARY_PREFIX?
:: set "CONDA_BUILD_SYSROOT=%CONDA_PREFIX%"

:: Remove or restore `cuda.lib` from the compiler sysroot.
LIBCUDA_SO_CONDA_NVCC_BACKUP="%CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib-conda-nvcc-backup"
if exist %LIBCUDA_SO_CONDA_NVCC_BACKUP% (
  ren "%LIBCUDA_SO_CONDA_NVCC_BACKUP%" "%CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib"
) else (
  del "%CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib"
)