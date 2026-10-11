@echo off
setlocal EnableExtensions DisableDelayedExpansion
call "%~dp0_lab-guard.cmd" ready
if errorlevel 1 exit /b 1
set "LAB_ROOT=%USERPROFILE%\CMD-Lab"
echo [TOUR] Directory entries:
dir /b "%LAB_ROOT%\data"
if errorlevel 1 exit /b 1
echo.
echo [TOUR] Directory tree:
tree "%LAB_ROOT%\data" /f /a
if errorlevel 1 exit /b 1
echo.
echo [TOUR] A file whose name contains spaces:
type "%LAB_ROOT%\data\notes with spaces.txt"
if errorlevel 1 exit /b 1
echo.
pushd "%LAB_ROOT%\data"
if errorlevel 1 exit /b 1
echo [TOUR] Current directory after pushd:
cd
popd
exit /b 0
