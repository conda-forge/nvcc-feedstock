@echo on
setlocal enableextensions enabledelayedexpansion || goto :error

:: Activation script
mkdir %PREFIX%\etc\conda\activate.d
:: Render conda-build env vars
sed -i "s/__LIBRARY_LIB__/%LIBRARY_LIB%/g;s/__PKG_VERSION__/%PKG_VERSION%/g" %RECIPE_DIR%\windows\activate.bat
copy %RECIPE_DIR%\windows\activate.bat %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat || goto :error

:: Deactivation script
mkdir %PREFIX%\etc\conda\deactivate.d
:: Render conda-build env vars
sed -i "s/__LIBRARY_LIB__/%LIBRARY_LIB%/g" %RECIPE_DIR%\windows\deactivate.bat
copy %RECIPE_DIR%\windows\deactivate.bat %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat || goto :error

:: nvcc executable wrapper
mkdir %LIBRARY_PREFIX%\bin
copy %RECIPE_DIR%\windows\nvcc_windows.bat %LIBRARY_PREFIX%\bin\nvcc.bat || goto :error

:: create an empty cuda.lib stub -- this should prevent accidental packaging of the real cuda.lib
:: using >> guarantees an existing %LIBRARY_PREFIX%\lib\cuda.lib will not get overwritten
mkdir %LIBRARY_PREFIX%\lib
type nul >> %LIBRARY_PREFIX%\lib\cuda.lib || goto :error

goto :EOF

:error
echo Failed with error %errorlevel%
exit /b %errorlevel%
