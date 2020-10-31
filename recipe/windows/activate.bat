:: Backup environment variables (only if the variables are set)
if defined CUDA_HOME (
  set "CUDA_HOME_CONDA_NVCC_BACKUP=%CUDA_HOME%"
)

if defined CFLAGS (
  set "CFLAGS_CONDA_NVCC_BACKUP=%CFLAGS%"
)

if defined CPPFLAGS (
  set "CPPFLAGS_CONDA_NVCC_BACKUP=%CPPFLAGS%"
)

if defined CXXFLAGS (
  set "CXXFLAGS_CONDA_NVCC_BACKUP=%CXXFLAGS%"
)

:: Default to using \$(cuda-gdb) to specify \$(CUDA_HOME).
if not defined CUDA_HOME (
    for /f "usebackq tokens=*" %%a in (`where cuda-gdb`) do set "CUDA_GDB_EXECUTABLE=%%a" || goto :error
    if "%CUDA_GDB_EXECUTABLE%"=="" (
        echo "Cannot determine CUDA_HOME: cuda-gdb not in PATH"
        exit /b 1
    ) else (
        for /f "usebackq tokens=*" %%a in (`python -c "from pathlib import Path; print(Path('%CUDA_GDB_EXECUTABLE%').parents[1])"`) do set "CUDA_HOME=%%a" || goto :error
    )
)

if not exist "%CUDA_HOME%\" (
    echo "Directory specified in CUDA_HOME(=%CUDA_HOME%) doesn't exist"
    exit /b 1
)

if not exist "%CUDA_HOME%/lib64/stubs/libcuda.so" (
    echo "File %CUDA_HOME%/lib64/stubs/libcuda.so doesn't exist"
    exit /b 1
)

grep -q "CUDA Version %PKG_VERSION%" %CUDA_HOME%/version.txt
if errorlevel 1 (
    echo "Version of installed CUDA didn't match package"
    exit /b 1
)

set "CUDA_HOME=%CUDA_HOME%"
set "CFLAGS=%CFLAGS% -I%CUDA_HOME%\include"
set "CPPFLAGS=%CPPFLAGS% -I%CUDA_HOME%\include"
set "CXXFLAGS=%CXXFLAGS% -I%CUDA_HOME%\include"

:: JRG: Do we need this on Windows?

:: JRG: Should CONDA_BUILD_SYSROOT be replaced with LIBRARY_PREFIX?
:: set "CONDA_BUILD_SYSROOT=%CONDA_PREFIX%"
mkdir "%CONDA_BUILD_SYSROOT%\lib"

:: Add `cuda.lib` shared object stub to the compiler sysroot.
:: Needed for things that want to link to `cuda.lib`.
:: Stub is used to avoid getting driver code linked into binaries.

:: Make a backup of `cuda.lib` if it exists
if exist %CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib (
  set "LIBCUDA_SO_CONDA_NVCC_BACKUP=%CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib-conda-nvcc-backup"
  mv "%CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib" "%LIBCUDA_SO_CONDA_NVCC_BACKUP%"

)
copy "%CUDA_HOME%\lib\x64\cuda.lib%" "%CONDA_BUILD_SYSROOT%\lib\x64\cuda.lib"
