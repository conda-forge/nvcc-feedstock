:: Generate nvcuda.stub.lib
:: MSVC must be active
@echo off
if not exist "C:\Windows\system32\nvcuda.dll" (
    echo "nvcuda.dll needs to be present in system"
    exit 1
)

:: Export symbols
dumpbin /EXPORTS C:\Windows\system32\nvcuda.dll > nvcuda.exports

:: Extract names automatically
echo EXPORTS > nvcuda.def
for /F "usebackq tokens=4" %%a in (`findstr /R /C:" cu.*" nvcuda.exports`) DO (
    echo __imp_%%a >> nvcuda.def
    echo %%a >> nvcuda.def
)

:: Generate lib
lib /def:nvcuda.def /out:nvcuda.stub.lib