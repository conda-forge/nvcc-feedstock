@echo on
setlocal enableextensions enabledelayedexpansion || goto :error

:: Activation script
mkdir %PREFIX%\etc\conda\activate.d
copy %RECIPE_DIR%\windows\activate.bat %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat || goto :error

:: Deactivation script
mkdir %PREFIX%\etc\conda\deactivate.d
copy %RECIPE_DIR%\windows\deactivate.bat %PREFIX%\etc\conda\deactivate.d\%PKG_NAME%_deactivate.bat || goto :error

:: nvcc executable wrapper
mkdir %LIBRARY_PREFIX%\bin
copy %RECIPE_DIR%\windows\nvcc_windows.bat %LIBRARY_PREFIX%\bin\nvcc.bat || goto :error

:: generate cuda.lib stub
mkdir %LIBRARY_PREFIX%\lib
call %RECIPE_DIR%\windows\generate_stub.bat || goto :error
copy cuda.stub.lib  %LIBRARY_PREFIX%\lib\cuda.lib || goto :error

goto :EOF

:error
echo Failed with error %errorlevel%
exit /b %errorlevel%
