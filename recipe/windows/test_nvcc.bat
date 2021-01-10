@REM @echo on

@REM :: Verify the cuda stub library exists.
@REM if not exist "%LIBRARY_LIB%\cuda.lib" (
@REM     echo "%LIBRARY_LIB%\cuda.lib is not a file"
@REM     exit 1
@REM )

@REM if not exist "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat" (
@REM     echo "%PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat is not a file"
@REM     exit 1
@REM )

@REM if not exist "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat" (
@REM     echo "%PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat is not a file"
@REM     exit 1
@REM )

@REM :: Try using the activation scripts.
@REM if defined CUDA_HOME (
@REM     echo "CUDA_HOME is set to '%CUDA_HOME%'"
@REM ) else (
@REM     echo "CUDA_HOME is unset after activation"
@REM     exit 1
@REM )
@REM set "TEST_CUDA_HOME_INITIAL=%CUDA_HOME_CONDA_NVCC_BACKUP%"

@REM call %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat
@REM if errorlevel 1 exit 1

@REM if "%CUDA_HOME%"=="" (
@REM     if "%TEST_CUDA_HOME_INITIAL%"=="" (
@REM         echo "CUDA_HOME correctly unset after deactivation"
@REM     )
@REM ) else (
@REM     if not "%TEST_CUDA_HOME_INITIAL%"=="" (
@REM         echo "CUDA_HOME correctly maintained as '%CUDA_HOME%' after deactivation"
@REM     ) else (
@REM         echo "CUDA_HOME is incorrectly set to '%CUDA_HOME%' after deactivation"
@REM         exit 1
@REM     )

@REM )


@REM :: Manually trigger the activation script
@REM call %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat
@REM if errorlevel 1 exit 1

@REM :: Check activation worked as expected, then deactivate
@REM if "%CUDA_HOME%"=="" (
@REM     echo "CUDA_HOME is unset after activation"
@REM     exit 1
@REM ) else (
@REM     echo "CUDA_HOME is set to '%CUDA_HOME%'"
@REM )
@REM call %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat
@REM if errorlevel 1 exit 1

@REM :: If no previous cuda.lib was present, there shouldn't be any!
@REM if "%CUDALIB_CONDA_NVCC_BACKUP%" == "" (
@REM     if exist "%LIBRARY_LIB%\cuda.lib" (
@REM         echo "%LIBRARY_LIB%\cuda.lib" should not exist!
@REM         exit 1
@REM     )
@REM )

@REM :: Reactivate
@REM call %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat
@REM if errorlevel 1 exit 1

@REM :: Try building something
@REM call nvcc test.cu

:: Try different CMake setups
cd cmake-tests/

SETLOCAL EnableDelayedExpansion
set count=0
set exitcode=0
set summary=

:: This hack is required to store newlines... T_T
(set \n=^
%=This is Mandatory Space=%
)

for %%F in (
    "         -DWITH_ENABLE_LANGUAGE=OFF -DCUDA_FINDER=CUDA       "
    "         -DWITH_ENABLE_LANGUAGE=OFF -DCUDA_FINDER=CUDAToolkit"
    "         -DWITH_ENABLE_LANGUAGE=ON  -DCUDA_FINDER=CUDA       "
    "         -DWITH_ENABLE_LANGUAGE=ON  -DCUDA_FINDER=CUDAToolkit"
    "         -DWITH_ENABLE_LANGUAGE=ON  -DCUDA_FINDER=OFF        "
    " -GNinja -DWITH_ENABLE_LANGUAGE=OFF -DCUDA_FINDER=CUDA       "
    " -GNinja -DWITH_ENABLE_LANGUAGE=OFF -DCUDA_FINDER=CUDAToolkit"
    " -GNinja -DWITH_ENABLE_LANGUAGE=ON  -DCUDA_FINDER=CUDA       "
    " -GNinja -DWITH_ENABLE_LANGUAGE=ON  -DCUDA_FINDER=CUDAToolkit"
     "-GNinja -DWITH_ENABLE_LANGUAGE=ON  -DCUDA_FINDER=OFF        "
) do (
    set /a count=!count!+1
    echo.
    echo.
    echo --------
    echo Test #!count!: %%~F
    echo --------
    echo.
    echo.

    rmdir /s /q build
    mkdir build
    cd build
    cmake !CMAKE_ARGS! %%~F ..
    cmake --build .
    .\diana
    set thisexitcode=!errorlevel!
    set summary=!summary!#!count!: %%~F:
    if "!thisexitcode!" == "0" ( set "summary=!summary! OK!\n!" ) else ( set "summary=!summary! FAILED!\n!" )
    set /a exitcode=!exitcode!+!thisexitcode!
    cd ..
)
echo.
echo --------------------
echo Summary of run tests
echo --------------------
echo.
echo !summary!
exit %exitcode%
