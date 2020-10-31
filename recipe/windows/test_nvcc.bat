@echo on

:: Verify the symlink to the libcuda stub library exists.
test "$(realpath $(%CC% --print-sysroot))" = "$(realpath %CONDA_BUILD_SYSROOT%)"
if not exist "%CONDA_BUILD_SYSROOT%\lib\libcuda.so"(
    echo "%CONDA_BUILD_SYSROOT%\lib\libcuda.so is not a file"
    exit \b 1
)

if not exist "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat" (
    echo "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat is not a file"
    exit \b 1
)

if not exist "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat" (
    echo "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat is not a file"
    exit \b 1
)

:: Try using the activation scripts.
if defined CUDA_HOME (
    echo "CUDA_HOME is set to %CUDA_HOME%"
) else (
    echo "CUDA_HOME is unset after activation"
    exit \b 1
)

%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat
if "%CUDA_HOME%"=="" (
    if "%TEST_CUDA_HOME_INITIAL%"=="" (
        echo "CUDA_HOME correctly unset after deactivation"
    )
) else (
    if not "%CUDA_HOME%"=="" (
        if not "%TEST_CUDA_HOME_INITIAL%"=="" (
            echo "CUDA_HOME correctly maintained as '%CUDA_HOME%' after deactivation"
        ) else (
            echo "CUDA_HOME is incorrectly set to '%CUDA_HOME%' after deactivation"
            exit \b 1
        )
    )
)


:: Set some CFLAGS to make sure we're not causing side effects
set "CFLAGS_CONDA_NVCC_TEST_BACKUP=%CFLAGS%"
set "CFLAGS=%CFLAGS% -I\path\to\test\include"
set "CFLAGS_CONDA_NVCC_TEST=%CFLAGS%"

:: Manually trigger the activation script
%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat

:: Check activation worked as expected, then deactivate
if "%CUDA_HOME%"=="" (
    echo "CUDA_HOME is unset after activation"
    exit \b 1
) else (
    echo "CUDA_HOME is set to '%CUDA_HOME%'"
fi

%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat

:: Make sure there's no side effects
if "%CFLAGS%"=="%CFLAGS_CONDA_NVCC_TEST%" (
    echo "CFLAGS correctly maintained as '%CFLAGS%'"
    set "CFLAGS_CONDA_NVCC_TEST="
    set "CFLAGS=%CFLAGS_CONDA_NVCC_TEST_BACKUP%"
    set "CFLAGS_CONDA_NVCC_TEST_BACKUP="
) else (
    echo "CFLAGS is incorrectly set to '%CFLAGS%', should be set to '%CFLAGS_CONDA_NVCC_TEST%'"
    exit \b 1
)

:: Reactivate
%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat


:: Try building something
nvcc ..\test.cu
