@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "KIT_DIR=%~dp0"
call :run_step "00-create-lab.cmd"
if errorlevel 1 exit /b 1
call :run_step "01-file-tour.cmd"
if errorlevel 1 exit /b 1
call :run_step "02-search-report.cmd"
if errorlevel 1 exit /b 1
call :run_step "03-backup-demo.cmd"
if errorlevel 1 exit /b 1
call "%KIT_DIR%04-arguments.cmd" /name "Lan Nguyen"
if errorlevel 1 exit /b 1
call "%KIT_DIR%04-arguments.cmd" /name Unsupported
set "ARG_RC=%ERRORLEVEL%"
if not "%ARG_RC%"=="2" (
    echo [FAIL] Expected unsupported arguments to return 2.
    exit /b 1
)
echo [PASS] Unsupported arguments returned 2 as expected.
call :run_step "05-loops.cmd"
if errorlevel 1 exit /b 1
call :run_step "06-errorlevels.cmd"
if errorlevel 1 exit /b 1
call :run_step "09-verify-lab.cmd"
if errorlevel 1 exit /b 1
echo [PASS] All exercises passed. Backup was a dry run.
echo Optional next step: 03-backup-demo.cmd /apply
exit /b 0
:run_step
echo.
echo [RUN] %~1
call "%KIT_DIR%%~1"
set "STEP_RC=%ERRORLEVEL%"
if not "%STEP_RC%"=="0" (
    echo [FAIL] "%~1" returned %STEP_RC%.
    exit /b 1
)
exit /b 0
