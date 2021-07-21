@ECHO OFF

:: check if ccbin is already in the argv
:: hint: CMD 'string contains' checks are weird; see
:: https://stackoverflow.com/a/7006016 and
:: https://stackoverflow.com/a/6310580 for more info
FOR %%A IN (%*) DO (
    ECHO %%A | FINDSTR /C:"-ccbin"            >nul && ( GOTO noccbin )
    ECHO %%A | FINDSTR /C:"--compiler-bindir" >nul && ( GOTO noccbin )
)
:: ccbin was not passed already; we add it ourselves
GOTO ccbin

:noccbin
"%CUDA_HOME%\bin\nvcc.exe" %*
GOTO :EOF

:ccbin
"%CUDA_HOME%\bin\nvcc.exe" -ccbin "%CXX%" %*
