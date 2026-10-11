@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "COPY_MODE=/L"
if "%~1"=="" goto args_ok
if /i not "%~1"=="/apply" goto usage
if not "%~2"=="" goto usage
set "COPY_MODE="
:args_ok
call "%~dp0_lab-guard.cmd" ready
if errorlevel 1 exit /b 1
set "LAB_ROOT=%USERPROFILE%\CMD-Lab"
if defined COPY_MODE echo [DRY RUN] /L is active. No backup files will be copied.
if not defined COPY_MODE echo [APPLY] Copying only training data to backups\demo.
robocopy "%LAB_ROOT%\data" "%LAB_ROOT%\backups\demo" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP %COPY_MODE%
set "ROBO_RC=%ERRORLEVEL%"
echo [ROBOCOPY] Raw exit code: %ROBO_RC%
if %ROBO_RC% geq 8 (
    echo [FAIL] Robocopy reported a failure.
    exit /b 1
)
echo [OK] Robocopy codes 0 through 7 are nonfatal status codes.
exit /b 0
:usage
echo Usage: 03-backup-demo.cmd [ /apply ]
echo With no argument, the script uses /L to preview the copy.
exit /b 2
