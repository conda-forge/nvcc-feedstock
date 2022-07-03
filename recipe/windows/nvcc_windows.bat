for /f "tokens=* usebackq" %%f in (`where cl.exe`) do (set "CONDA_NVCC_CCBIN=%%~dpf:\=\\%%")
"%CUDA_HOME%\bin\nvcc.exe" --use-local-env -ccbin "%CONDA_NVCC_CCBIN%" %*
