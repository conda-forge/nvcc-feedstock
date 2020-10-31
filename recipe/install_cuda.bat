@echo off

set CUDA_VERSION=None

shyaml -h || echo ERROR! shyaml not installed but is required!

:: Pipe $CONFIG.yaml into shyaml and output `cuda_compiler_version` to temporary file `cuda.version`
<.ci_config\%CONFIG%.yaml shyaml get-value cuda_compiler_version.0 None > cuda.version
<cuda.version set /p CUDA_VERSION=

if "%CUDA_VERSION%" == "None" (
    echo Skipping CUDA install...
    goto after_cuda
)

set /a CUDA_VER=%CUDA_VERSION%
set CUDA_VER_MAJOR=%CUDA_VERSION:~0,-1%
set CUDA_VER_MINOR=%CUDA_VERSION:~-1,1%
set CUDA_VERSION_STR=%CUDA_VER_MAJOR%.%CUDA_VER_MINOR%

if %CUDA_VER% EQU 92 goto cuda92
if %CUDA_VER% EQU 100 goto cuda100
if %CUDA_VER% EQU 101 goto cuda101
if %CUDA_VER% EQU 102 goto cuda102
if %CUDA_VER% EQU 110 goto cuda110

echo CUDA %CUDA_VERSION_STR% is not supported
exit /b 1

:: Define URLs per version
:cuda92
set "CUDA_INSTALLER_URL=https://developer.nvidia.com/compute/cuda/9.2/Prod2/network_installers2/cuda_9.2.148_win10_network"
set "CUDA_INSTALLER_CHECKSUM=a4e122df19d8fa20ec45d2ffebcf81cdcf8f44544dd67f7590ee613596f4634c"
goto cuda_common


:cuda100
set "CUDA_INSTALLER_URL=https://developer.nvidia.com/compute/cuda/10.0/Prod/network_installers/cuda_10.0.130_win10_network"
set "CUDA_INSTALLER_CHECKSUM=903bbcc079fc2db04be82e9df9d5b925ffbb36f2df6a77e9706c3a8797decc22"
goto cuda_common


:cuda101
set "CUDA_INSTALLER_URL=http://developer.download.nvidia.com/compute/cuda/10.1/Prod/network_installers/cuda_10.1.243_win10_network.exe"
set "CUDA_INSTALLER_CHECKSUM=9eee3c596aae4c001376a0e793f28f88d438cefe50af0c727d6fe9d80db19df2"
goto cuda_common


:cuda102
set "CUDA_INSTALLER_URL=http://developer.download.nvidia.com/compute/cuda/10.2/Prod/network_installers/cuda_10.2.89_win10_network.exe"
set "CUDA_INSTALLER_CHECKSUM=548dbd2ac5698d93ebecd8d19518dd6ee012612c692bb64b43643165bb715953"
goto cuda_common


:cuda110
set "CUDA_INSTALLER_URL=http://developer.download.nvidia.com/compute/cuda/11.0.3/network_installers/cuda_11.0.3_win10_network.exe"
set "CUDA_INSTALLER_CHECKSUM=598eec64474952f4caa0283398b2e584f8a80db4699075eab65bdf93eb1904b5"
goto cuda_common


:: The actual installation logic
:cuda_common

echo Downloading CUDA version %CUDA_VERSION_STR% installer from %CUDA_INSTALLER_URL%
echo Expected SHA256: %CUDA_INSTALLER_CHECKSUM%

:: Download installer
curl -k -L %CUDA_INSTALLER_URL% --output cuda_installer.exe
if errorlevel 1 (
    echo Problem downloading installer...
    exit /b 1
)

:: Check sha256
openssl sha256 cuda_installer.exe | findstr %CUDA_INSTALLER_CHECKSUM%
if errorlevel 1 (
    echo Checksum does not match!
    exit /b 1
)

:: Run installer
cuda_installer.exe -s
if errorlevel 1 (
    echo Problem running installer...
    exit /b 1
)

:after_cuda
echo Continuing with rest of the script...
