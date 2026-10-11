@echo off
setlocal EnableExtensions DisableDelayedExpansion
call "%~dp0_lab-guard.cmd" prepare
if errorlevel 1 exit /b 1
set "LAB_ROOT=%USERPROFILE%\CMD-Lab"
call :copy_fixture "readme.txt"
if errorlevel 1 exit /b 1
call :copy_fixture "notes with spaces.txt"
if errorlevel 1 exit /b 1
call :copy_fixture "customers.csv"
if errorlevel 1 exit /b 1
call :copy_fixture "logs\app.log"
if errorlevel 1 exit /b 1
call :copy_fixture "code\hello.cmd"
if errorlevel 1 exit /b 1
echo [OK] Lab ready: "%LAB_ROOT%"
echo Existing data files were kept. Run 09-verify-lab.cmd to check fixtures.
exit /b 0

:copy_fixture
if exist "%LAB_ROOT%\data\%~1\" (
    echo [FAIL] Expected a file: "%LAB_ROOT%\data\%~1"
    exit /b 1
)
if exist "%LAB_ROOT%\data\%~1" (
    echo [KEEP] "%~1"
    exit /b 0
)
if not exist "%~dp0fixtures\%~1" (
    echo [FAIL] Missing kit fixture: "%~1"
    exit /b 1
)
copy /y "%~dp0fixtures\%~1" "%LAB_ROOT%\data\%~1" >nul
if errorlevel 1 exit /b 1
echo [COPY] "%~1"
exit /b 0
