@echo off
setlocal EnableExtensions DisableDelayedExpansion
cmd /d /c exit /b 7
set "DEMO_RC=%ERRORLEVEL%"
if not "%DEMO_RC%"=="7" (
    echo [FAIL] Expected raw exit code 7.
    exit /b 1
)
echo [RC] Captured immediately: %DEMO_RC%
cmd /d /c exit /b 7
if errorlevel 8 goto unexpected
if errorlevel 7 goto threshold_ok
:unexpected
echo [FAIL] IF ERRORLEVEL threshold demonstration failed.
exit /b 1
:threshold_ok
echo [RC] IF ERRORLEVEL 7 means greater than or equal to 7.
cmd /d /c exit /b 0 && echo [CHAIN] Success branch ran.
cmd /d /c exit /b 3 || echo [CHAIN] Failure branch ran as expected.
echo [OK] Internal failures were intentional; this exercise returns 0.
exit /b 0
