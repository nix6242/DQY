@echo off
setlocal EnableExtensions DisableDelayedExpansion
rem Only the two trusted demonstration names below are accepted.
rem Do not pass untrusted shell text to this or any batch script.
set "DEMO_NAME=Alice"
if "%~1"=="" goto args_ok
if /i not "%~1"=="/name" goto usage
if not "%~3"=="" goto usage
set "DEMO_NAME="
if /i "%~2"=="Alice" set "DEMO_NAME=Alice"
if /i "%~2"=="Lan Nguyen" set "DEMO_NAME=Lan Nguyen"
if not defined DEMO_NAME goto usage
:args_ok
call "%~dp0_lab-guard.cmd" ready
if errorlevel 1 exit /b 1
echo [ARG] Hello, %DEMO_NAME%.
echo [ARG] Script name: "%~nx0"
echo [ARG] Script directory: "%~dp0"
echo [ARG] Full script path: "%~f0"
echo [ARG] Allowed examples: /name Alice or /name "Lan Nguyen"
exit /b 0
:usage
echo Usage: 04-arguments.cmd [ /name Alice ]
echo        04-arguments.cmd /name "Lan Nguyen"
echo Only these known names are accepted in this exercise.
exit /b 2
