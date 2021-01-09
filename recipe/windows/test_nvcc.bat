@echo on

:: Verify the cuda stub library exists.
if not exist "%LIBRARY_LIB%\cuda.lib" (
    echo "%LIBRARY_LIB%\cuda.lib is not a file"
    exit 1
)

if not exist "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat" (
    echo "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat is not a file"
    exit 1
)

if not exist "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat" (
    echo "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat is not a file"
    exit 1
)

:: Try using the activation scripts.
if defined CUDA_HOME (
    echo "CUDA_HOME is set to '%CUDA_HOME%'"
) else (
    echo "CUDA_HOME is unset after activation"
    exit 1
)
set "TEST_CUDA_HOME_INITIAL=%CUDA_HOME_CONDA_NVCC_BACKUP%"

call %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat
if errorlevel 1 exit 1

if "%CUDA_HOME%"=="" (
    if "%TEST_CUDA_HOME_INITIAL%"=="" (
        echo "CUDA_HOME correctly unset after deactivation"
    )
) else (
    if not "%TEST_CUDA_HOME_INITIAL%"=="" (
        echo "CUDA_HOME correctly maintained as '%CUDA_HOME%' after deactivation"
    ) else (
        echo "CUDA_HOME is incorrectly set to '%CUDA_HOME%' after deactivation"
        exit 1
    )

)


:: Manually trigger the activation script
call %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat
if errorlevel 1 exit 1

:: Check activation worked as expected, then deactivate
if "%CUDA_HOME%"=="" (
    echo "CUDA_HOME is unset after activation"
    exit 1
) else (
    echo "CUDA_HOME is set to '%CUDA_HOME%'"
)
call %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat
if errorlevel 1 exit 1

:: If no previous cuda.lib was present, there shouldn't be any!
if "%CUDALIB_CONDA_NVCC_BACKUP%" == "" (
    if exist "%LIBRARY_LIB%\cuda.lib" (
        echo "%LIBRARY_LIB%\cuda.lib" should not exist!
        exit 1
    )
)

:: Reactivate
call %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat
if errorlevel 1 exit 1

:: Try building something
nvcc test.cu


:: Try different CMake setups
cd cmake-tests/

for %%F in (
    "-DWITH_FINDCUDA=ON -DWITH_FINDCUDATOOLKIT=OFF -DWITH_ENABLE_LANGUAGE=OFF"
    "-DWITH_FINDCUDA=ON -DWITH_FINDCUDATOOLKIT=OFF -DWITH_ENABLE_LANGUAGE=ON"
    "-DWITH_FINDCUDA=OFF -DWITH_FINDCUDATOOLKIT=ON -DWITH_ENABLE_LANGUAGE=ON"
) do (
    echo Testing for %%~F
    mkdir build
    cd build
    cmake %CMAKE_ARGS% %%~F ..
    jom
    ./diana
    cd ..
    rmdir /s /q build
)
