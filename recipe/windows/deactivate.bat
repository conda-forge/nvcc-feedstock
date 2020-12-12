:: Restore environment variables (if there is anything to restore)
if not "%CUDA_HOME_CONDA_NVCC_BACKUP%"=="" (
    set "CUDA_HOME=%CUDA_HOME_CONDA_NVCC_BACKUP%"
    set "CUDA_HOME_CONDA_NVCC_BACKUP="
)

if not "%CUDA_PATH_CONDA_NVCC_BACKUP%"=="" (
    set "CUDA_PATH=%CUDA_PATH_CONDA_NVCC_BACKUP%"
    set "CUDA_PATH_CONDA_NVCC_BACKUP="
    :: If there's a backup for CUDA_PATH but not for CUDA_HOME
    :: that means we aliased it during env activation
    if "%CUDA_HOME_CONDA_NVCC_BACKUP%"=="" (
        set "CUDA_HOME="
    )
)

if not "%CFLAGS_CONDA_NVCC_BACKUP:"=%"=="" (
    (set CFLAGS=%CFLAGS_CONDA_NVCC_BACKUP%)
    set "CFLAGS_CONDA_NVCC_BACKUP="
)

if not "%CPPFLAGS_CONDA_NVCC_BACKUP:"=%"=="" (
    (set CPPFLAGS=%CPPFLAGS_CONDA_NVCC_BACKUP%)
    set "CPPFLAGS_CONDA_NVCC_BACKUP="
)

if not "%CXXFLAGS_CONDA_NVCC_BACKUP:"=%"=="" (
    (set CXXFLAGS=%CXXFLAGS_CONDA_NVCC_BACKUP%)
    set "CXXFLAGS_CONDA_NVCC_BACKUP="
)

:: Remove or restore `cuda.lib` from the compiler sysroot.
set "CUDALIB_CONDA_NVCC_BACKUP=%CONDA_PREFIX%\Library\lib\cuda.lib-conda-nvcc-backup"
if exist "%CUDALIB_CONDA_NVCC_BACKUP%" (
    ren "%CUDALIB_CONDA_NVCC_BACKUP%" "%CONDA_PREFIX%\Library\lib\cuda.lib"
) else (
    :: We shouldn't need this because we did create an empty one just in case
    del "%CONDA_PREFIX%\Library\lib\cuda.lib"
    if errorlevel 1 (
        echo Could not remove `cuda.lib` stub!
        exit /b 1
    )
)
