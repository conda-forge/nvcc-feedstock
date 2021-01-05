:: Restore environment variables (if there is anything to restore)
set "CUDA_HOME=%CUDA_HOME_CONDA_NVCC_BACKUP%"
set "CUDA_HOME_CONDA_NVCC_BACKUP="
set "CUDA_PATH=%CUDA_PATH_CONDA_NVCC_BACKUP%"
set "CUDA_PATH_CONDA_NVCC_BACKUP="
set "INCLUDE=%INCLUDE_CONDA_NVCC_BACKUP%"
set "INCLUDE_CONDA_NVCC_BACKUP="
set "CudaToolkitDir=%CudaToolkitDir_CONDA_NVCC_BACKUP%"
set "CudaToolkitDir_CONDA_NVCC_BACKUP="

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
