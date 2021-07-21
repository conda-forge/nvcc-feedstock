@ECHO OFF
setlocal enabledelayedexpansion

:: check if ccbin is already in the argv
:: hint: CMD 'string contains' checks are weird; see
:: https://stackoverflow.com/a/7006016 and
:: https://stackoverflow.com/a/6310580 for more info
FOR %%A IN (%*) DO (
    SET arg=%%A
    IF NOT x!arg:-ccbin=!==x!arg!             GOTO noccbin
    IF NOT x!arg:--compiler-bindir=!==x!arg!  GOTO noccbin
)
:: ccbin was not passed already; we add it ourselves
GOTO ccbin

:noccbin
"%CUDA_HOME%\bin\nvcc.exe" %*
GOTO :EOF

:ccbin
"%CUDA_HOME%\bin\nvcc.exe" -ccbin "%CXX%" %*
