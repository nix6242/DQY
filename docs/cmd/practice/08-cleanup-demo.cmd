@echo off
setlocal EnableExtensions DisableDelayedExpansion
if /i not "%~1"=="/confirm" goto usage
if not "%~2"=="" goto usage
call "%~dp0_lab-guard.cmd" ready
if errorlevel 1 exit /b 1
set "LAB_ROOT=%USERPROFILE%\CMD-Lab"
if not exist "%LAB_ROOT%\outputs\report.txt" (
    echo [OK] No generated report to remove.
    exit /b 0
)
call "%~dp0_lab-guard.cmd" cleanup-verify
if errorlevel 1 exit /b 1
rem The guard checked marker, reparse points, and the current report hash.
del /q "%LAB_ROOT%\outputs\report.txt"
if exist "%LAB_ROOT%\outputs\report.txt" (
    echo [FAIL] Report could not be removed.
    exit /b 1
)
del /q "%LAB_ROOT%\outputs\report.sha256"
if exist "%LAB_ROOT%\outputs\report.sha256" (
    echo [FAIL] Hash manifest could not be removed.
    exit /b 1
)
echo [OK] Removed only the unchanged generated report and its hash.
echo Data, backups, markers, exercises and the lab root were kept.
exit /b 0
:usage
echo Usage: 08-cleanup-demo.cmd /confirm
echo Removes only the unchanged generated report.txt and report.sha256.
exit /b 2
