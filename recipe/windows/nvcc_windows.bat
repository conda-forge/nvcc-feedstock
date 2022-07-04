for /f "tokens=* usebackq" %%f in (`where cl.exe`) do (set "dummy=%%~dpf" && call set "CONDA_NVCC_CCBIN=%%dummy:\=\\%%")
"%CUDA_HOME%\bin\nvcc.exe" --use-local-env -ccbin "%CONDA_NVCC_CCBIN%" %*
