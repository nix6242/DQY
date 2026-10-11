@echo off
setlocal EnableExtensions DisableDelayedExpansion
call "%~dp0_lab-guard.cmd" report-write
if errorlevel 1 exit /b 1
set "LAB_ROOT=%USERPROFILE%\CMD-Lab"
rem CreateNew refuses an existing candidate file. No old report is touched.
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; try { $p=Join-Path (Join-Path $env:USERPROFILE 'CMD-Lab') 'outputs\report.pending.txt'; $s=[IO.File]::Open($p,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None); $s.Dispose(); exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
if errorlevel 1 exit /b 1
cmd /d /c exit /b 0
>"%LAB_ROOT%\outputs\report.pending.txt" echo DQY CMD LAB GENERATED REPORT V1
if errorlevel 1 goto build_failed
cmd /d /c exit /b 0
>>"%LAB_ROOT%\outputs\report.pending.txt" echo Search: ERROR in data\logs\app.log
if errorlevel 1 goto build_failed
findstr /n /i /c:"ERROR" "%LAB_ROOT%\data\logs\app.log" >>"%LAB_ROOT%\outputs\report.pending.txt"
set "SEARCH_RC=%ERRORLEVEL%"
if %SEARCH_RC% geq 2 goto build_failed
rem findstr 0 = match, 1 = no match, 2 or more = error.
rem NullString passes real null to .NET on Windows PowerShell 5.1.
rem Replace each completed file atomically; the pair is not a database transaction.
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; try { $out=Join-Path (Join-Path $env:USERPROFILE 'CMD-Lab') 'outputs'; $candidate=Join-Path $out 'report.pending.txt'; $report=Join-Path $out 'report.txt'; $pendingHash=Join-Path $out 'report.sha256.pending.txt'; $manifest=Join-Path $out 'report.sha256'; $lines=[IO.File]::ReadAllLines($candidate); if ($lines.Length -lt 2 -or $lines[0] -cne 'DQY CMD LAB GENERATED REPORT V1' -or $lines[1] -cne 'Search: ERROR in data\logs\app.log') { throw 'Candidate report is incomplete.' }; $h=(Get-FileHash -LiteralPath $candidate -Algorithm SHA256).Hash; $bytes=[Text.Encoding]::ASCII.GetBytes($h+[Environment]::NewLine); $s=[IO.File]::Open($pendingHash,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None); try { $s.Write($bytes,0,$bytes.Length) } finally { $s.Dispose() }; if (Test-Path -LiteralPath $report) { [IO.File]::Replace($candidate,$report,[System.Management.Automation.Language.NullString]::Value) } else { [IO.File]::Move($candidate,$report) }; if (Test-Path -LiteralPath $manifest) { [IO.File]::Replace($pendingHash,$manifest,[System.Management.Automation.Language.NullString]::Value) } else { [IO.File]::Move($pendingHash,$manifest) }; exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
if errorlevel 1 goto build_failed
echo [OK] Report: "%LAB_ROOT%\outputs\report.txt"
type "%LAB_ROOT%\outputs\report.txt"
if errorlevel 1 exit /b 1
exit /b 0
:build_failed
echo [FAIL] Report was not finalized. Review any pending files manually.
echo Existing candidate files are never overwritten or silently deleted.
exit /b 1
