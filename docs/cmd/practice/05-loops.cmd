@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Verify the trusted CSV fixtures before the FOR /F parsing example.
call "%~dp009-verify-lab.cmd"
if errorlevel 1 exit /b 1
set "LAB_ROOT=%USERPROFILE%\CMD-Lab"
echo [LOOP] Two .txt files in the top-level data folder:
for %%F in ("%LAB_ROOT%\data\*.txt") do echo FILE "%%~nxF"
echo.
echo [LOOP] All data files, with delayed expansion disabled:
set "FILE_COUNT=0"
for /r "%LAB_ROOT%\data" %%F in (*) do (
    echo PATH "%%~fF"
    set /a "FILE_COUNT+=1" >nul
)
echo [LOOP] File count read after the loop: %FILE_COUNT%
if not "%FILE_COUNT%"=="5" exit /b 1
echo.
echo [LOOP] Simple trusted CSV: commas only, no quoted fields.
for /f "usebackq skip=1 tokens=1,2 delims=," %%A in ("%LAB_ROOT%\data\customers.csv") do echo ID="%%A" NAME="%%B"
echo [NOTE] FOR /F is not a full CSV parser.
exit /b 0
