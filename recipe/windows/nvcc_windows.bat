@ECHO OFF
:: check if ccbin is already in the argv
FOR %%A IN (%*) DO (
    IF %%A=="-ccbin"            GOTO noccbin
    IF %%A=="--compiler-bindir" GOTO noccbin
)
:: ccbin was not passed already; we add it ourselves
GOTO ccbin

:noccbin
"%CUDA_HOME%\bin\nvcc.exe" %*
GOTO :EOF

:ccbin
"%CUDA_HOME%\bin\nvcc.exe" -ccbin "%CXX%" %*
