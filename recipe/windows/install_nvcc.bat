setlocal enableextensions enabledelayedexpansion
if errorlevel 1 echo Unable to enable extensions

:: Activation script
mkdir %PREFIX%\etc\conda\activate.d || goto :error
copy %RECIPE_DIR%\windows\activate.bat %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat || goto :error

:: Deactivation script
mkdir %PREFIX%\etc\conda\deactivate.d || goto :error
copy %RECIPE_DIR%\windows\deactivate.bat %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat || goto :error

:: nvcc executable wrapper
copy %RECIPE_DIR%\windows\nvcc_windows.bat %LIBRARY_PREFIX%\bin\nvcc.bat || goto :error

:error
echo Failed with error %errorlevel%
exit /b %errorlevel%