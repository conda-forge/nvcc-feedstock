:: Backup environment variables (only if the variables are set)
if defined CUDA_HOME (
    set "CUDA_HOME_CONDA_NVCC_BACKUP=%CUDA_HOME%"
)

if defined CUDA_PATH (
    set "CUDA_PATH_CONDA_NVCC_BACKUP=%CUDA_PATH%"
    if not defined CUDA_HOME (
        set "CUDA_HOME=%CUDA_PATH%"
    )
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

:: Default to using nvcc.exe to specify %CUDA_HOME%
if not defined CUDA_PATH (
    for /f "usebackq tokens=*" %%a in (`where nvcc.exe`) do set "CUDA_NVCC_EXECUTABLE=%%a" || goto :error
    if "%CUDA_NVCC_EXECUTABLE%"=="" (
        echo "Cannot determine CUDA_PATH: nvcc.exe not in PATH"
        exit /b 1
    ) else (
        for /f "usebackq tokens=*" %%a in (`python -c "from pathlib import Path; print(Path('%CUDA_NVCC_EXECUTABLE%').parents[1])"`) do set "CUDA_PATH=%%a" || goto :error
    )
)

if not exist "%CUDA_PATH%\" (
    echo "Directory specified in CUDA_PATH(=%CUDA_PATH%) doesn't exist"
    exit /b 1
)

if not exist "%CUDA_PATH%\lib\x64\cuda.lib" (
    echo "File '%CUDA_PATH%\lib\x64\cuda.lib' doesn't exist"
    exit /b 1
)

findstr /C:"CUDA Version __PKG_VERSION__" "%CUDA_PATH%\version.txt"
if errorlevel 1 (
    :: CUDA 11 does not package a version.txt, so maybe it failed due to
    :: that. Let's double check with the output of nvcc.exe --version
    "%CUDA_PATH%\bin\nvcc.exe" --version | findstr /C:"release __PKG_VERSION__"
    if errorlevel 1 (
        echo "Version of installed CUDA didn't match package or could not be determined."
        exit /b 1
    )
)

set "CUDA_PATH=%CUDA_PATH%"
set "CUDA_HOME=%CUDA_PATH%"
set "CFLAGS=%CFLAGS% -I%CUDA_HOME%\include"
set "CPPFLAGS=%CPPFLAGS% -I%CUDA_HOME%\include"
set "CXXFLAGS=%CXXFLAGS% -I%CUDA_HOME%\include"

:: Add `cuda.lib` shared object stub to the compiler sysroot.
:: Needed for things that want to link to `cuda.lib`.
:: Stub is used to avoid getting driver code linked into binaries.

:: Make a backup of `cuda.lib` if it exists -- we make sure this is the case in install_nvcc.bat
if exist "__LIBRARY_LIB__\cuda.lib" (
    set "LIBCUDA_SO_CONDA_NVCC_BACKUP=__LIBRARY_LIB__\cuda.lib-conda-nvcc-backup"
    ren "__LIBRARY_LIB__\cuda.lib" "%LIBCUDA_SO_CONDA_NVCC_BACKUP%"
)

mkdir "__LIBRARY_LIB__"
:: symlinking requires admin access or developer mode ON
:: we fallback to a standard copy if mklink fails
mklink "__LIBRARY_LIB__\cuda.lib" "%CUDA_HOME%\lib\x64\cuda.lib" || copy "%CUDA_HOME%\lib\x64\cuda.lib" "__LIBRARY_LIB__\cuda.lib"
if errorlevel 1 (
    echo "Could not create link nor fallback copy"
    exit /b 1
)
