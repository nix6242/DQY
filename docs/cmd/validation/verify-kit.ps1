# CI-only Windows CMD validation. Never run on a personal machine.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$KitSource,
    [Parameter(Mandatory=$true)][string]$OutputReport
)
$ErrorActionPreference = 'Stop'
if ($env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_OS -ne 'Windows') {
    throw 'This test creates a disposable lab on a fresh GitHub Windows runner only.'
}
$checks = New-Object 'System.Collections.Generic.List[string]'
$runs = New-Object 'System.Collections.Generic.List[object]'
$kit = Join-Path $env:RUNNER_TEMP 'CMDKit Test!'
$lab = Join-Path $env:USERPROFILE 'CMD-Lab'
if (Test-Path -LiteralPath $lab) { throw 'Refusing to touch an existing lab.' }
if (Test-Path -LiteralPath $kit) { throw 'Test kit folder already exists.' }
New-Item -ItemType Directory -Path $kit | Out-Null
# Copy each source item explicitly; LiteralPath does not expand wildcards.
Get-ChildItem -LiteralPath $KitSource -Force | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $kit -Recurse -Force }
function Assert-Check([bool]$Condition,[string]$Message) {
    if (!$Condition) { throw ('FAIL: '+$Message) }
    $checks.Add($Message)
    Write-Host ('PASS: '+$Message)
}
function Run-Kit([string]$Script,[string]$Arguments='',[int]$Expected=0,[switch]$NonZero) {
    $path = Join-Path $kit $Script
    $command = '""'+$path+'"'
    if ($Arguments.Length -gt 0) { $command += ' '+$Arguments }
    $command += '"'
    $oldPreference=$ErrorActionPreference
    $ErrorActionPreference='Continue'
    try { $result=& $env:ComSpec /d /s /c $command 2>&1; $code=$LASTEXITCODE }
    finally { $ErrorActionPreference=$oldPreference }
    $text=($result | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    $runs.Add([pscustomobject]@{script=$Script;arguments=$Arguments;exitCode=$code;output=$text})
    Write-Host $text
    if ($NonZero) { Assert-Check ($code -ne 0) ($Script+' rejects unsafe/invalid case') }
    else { Assert-Check ($code -eq $Expected) ($Script+' returns '+$Expected+' '+$Arguments) }
    return [pscustomobject]@{Code=$code;Text=$text}
}
function Hash([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash }
try {
    # Existing unmarked folder must not be adopted or changed.
    New-Item -ItemType Directory -Path $lab | Out-Null
    $sentinel=Join-Path $lab 'keep.txt'
    [IO.File]::WriteAllText($sentinel,'owned by the CI test',[Text.Encoding]::ASCII)
    $sentinelHash=Hash $sentinel
    $null=Run-Kit '00-create-lab.cmd' -NonZero
    Assert-Check ((Hash $sentinel) -eq $sentinelHash) 'unmarked-folder sentinel preserved'
    Assert-Check (!(Test-Path -LiteralPath (Join-Path $lab '.cmd-lab-marker'))) 'unmarked root not adopted'
    Assert-Check (@(Get-ChildItem -LiteralPath $lab -Force).Count -eq 1) 'unmarked folder has no new files'
    # Remove only the CI-owned file and the now-empty directory, never recursively.
    Remove-Item -LiteralPath $sentinel
    [IO.Directory]::Delete($lab,$false)

    $null=Run-Kit '00-create-lab.cmd'
    $null=Run-Kit '09-verify-lab.cmd'
    $readme=Join-Path $lab 'data\readme.txt'
    $initialHash=Hash $readme
    $null=Run-Kit '00-create-lab.cmd'
    Assert-Check ((Hash $readme) -eq $initialHash) 'repeat initialization is idempotent'
    [IO.File]::AppendAllText($readme,'CI local edit'+[Environment]::NewLine,[Text.Encoding]::ASCII)
    $editedHash=Hash $readme
    $null=Run-Kit '00-create-lab.cmd'
    Assert-Check ((Hash $readme) -eq $editedHash) 'initialization keeps an edited source file'
    $null=Run-Kit '09-verify-lab.cmd' -NonZero
    [IO.File]::Copy((Join-Path $kit 'fixtures\readme.txt'),$readme,$true)
    $null=Run-Kit '09-verify-lab.cmd'

    # A pre-existing hash without a report must not be silently overwritten.
    $orphan=Join-Path $lab 'outputs\report.sha256'
    [IO.File]::WriteAllText($orphan,'user-owned orphan manifest',[Text.Encoding]::ASCII)
    $orphanHash=Hash $orphan
    $null=Run-Kit '02-search-report.cmd' -NonZero
    Assert-Check ((Hash $orphan) -eq $orphanHash) 'orphan manifest is preserved'
    Assert-Check (!(Test-Path -LiteralPath (Join-Path $lab 'outputs\report.txt'))) 'orphan case creates no report'
    $null=Run-Kit '09-verify-lab.cmd' -NonZero
    Remove-Item -LiteralPath $orphan

    $all=Run-Kit '07-run-all.cmd'
    Assert-Check ($all.Text.Contains('[PASS] All exercises passed. Backup was a dry run.')) 'run-all success message present'
    $backup=Join-Path $lab 'backups\demo'
    Assert-Check (!(Test-Path -LiteralPath $backup)) 'default backup does not create destination'
    $null=Run-Kit '03-backup-demo.cmd' '/apply'
    $expected=Get-Content -LiteralPath (Join-Path $kit 'expected-fixtures.json') -Raw | ConvertFrom-Json
    foreach ($file in $expected.files) {
        Assert-Check ((Hash (Join-Path $backup $file.path)) -ieq $file.sha256) ('applied backup hash: '+$file.path)
    }
    $extra=Join-Path $backup 'extra-kept.txt'
    [IO.File]::WriteAllText($extra,'destination-only file',[Text.Encoding]::ASCII)
    $extraHash=Hash $extra
    $null=Run-Kit '03-backup-demo.cmd' '/apply'
    Assert-Check ((Hash $extra) -eq $extraHash) 'backup preserves destination-only files without MIR'
    $null=Run-Kit '04-arguments.cmd' '/name "Lan Nguyen"'
    $null=Run-Kit '04-arguments.cmd' '/name Unsupported' 2
    $null=Run-Kit '06-errorlevels.cmd'
    & $env:ComSpec /d /c 'exit /b 7'
    Assert-Check ($LASTEXITCODE -eq 7) 'native child CMD exit code 7 observed'

    $report=Join-Path $lab 'outputs\report.txt'
    $manifest=Join-Path $lab 'outputs\report.sha256'
    $originalReport=[IO.File]::ReadAllBytes($report)
    $reportHash=Hash $report
    $null=Run-Kit '08-cleanup-demo.cmd' '' 2
    Assert-Check ((Hash $report) -eq $reportHash) 'cleanup without confirm keeps report'
    [IO.File]::AppendAllText($report,'user-edited line'+[Environment]::NewLine,[Text.Encoding]::ASCII)
    $editedReportHash=Hash $report
    $null=Run-Kit '08-cleanup-demo.cmd' '/confirm' -NonZero
    Assert-Check ((Hash $report) -eq $editedReportHash) 'cleanup refuses edited report'
    $null=Run-Kit '02-search-report.cmd' -NonZero
    Assert-Check ((Hash $report) -eq $editedReportHash) 'report rebuild refuses edited report'
    [IO.File]::WriteAllBytes($report,$originalReport)
    $reportItem=Get-Item -LiteralPath $report
    $reportItem.IsReadOnly=$true
    $null=Run-Kit '02-search-report.cmd' -NonZero
    Assert-Check ((Hash $report) -eq $reportHash) 'read-only report is preserved and build fails'
    $reportItem.IsReadOnly=$false
    $manifestItem=Get-Item -LiteralPath $manifest
    $manifestHash=Hash $manifest
    $manifestItem.IsReadOnly=$true
    $null=Run-Kit '02-search-report.cmd' -NonZero
    Assert-Check ((Hash $manifest) -eq $manifestHash) 'read-only manifest is preserved and build fails'
    Assert-Check ((Hash $report) -eq $reportHash) 'read-only manifest case also preserves report'
    $manifestItem.IsReadOnly=$false
    $null=Run-Kit '02-search-report.cmd'
    $null=Run-Kit '09-verify-lab.cmd'
    $null=Run-Kit '08-cleanup-demo.cmd' '/confirm'
    Assert-Check (!(Test-Path -LiteralPath $report)) 'confirmed cleanup removes generated report'
    Assert-Check (!(Test-Path -LiteralPath $manifest)) 'confirmed cleanup removes generated hash'
    Assert-Check (Test-Path -LiteralPath $readme -PathType Leaf) 'cleanup preserves source data'
    Assert-Check (Test-Path -LiteralPath (Join-Path $lab '.cmd-lab-marker') -PathType Leaf) 'cleanup preserves root and marker'
    Assert-Check ((Hash $extra) -eq $extraHash) 'cleanup preserves backup extra file'
    $null=Run-Kit '09-verify-lab.cmd'

    # A path containing ! is supported with delayed expansion disabled.
    $bang=Join-Path $lab 'data\bang!.txt'
    [IO.File]::WriteAllText($bang,'bang path fixture',[Text.Encoding]::ASCII)
    $bangHash=Hash $bang
    $null=Run-Kit '00-create-lab.cmd'
    $null=Run-Kit '01-file-tour.cmd'
    Assert-Check ((Hash $bang) -eq $bangHash) 'file named bang!.txt survives initialization and tour'
    $null=Run-Kit '03-backup-demo.cmd' '/apply'
    Assert-Check ((Hash (Join-Path $backup 'bang!.txt')) -eq $bangHash) 'backup supports filename containing !'
    Remove-Item -LiteralPath $bang

    # A junction must be rejected before any traversal/copy/deletion.
    $outside=Join-Path $env:RUNNER_TEMP 'CMDLab Outside Sentinel'
    New-Item -ItemType Directory -Path $outside | Out-Null
    $outsideFile=Join-Path $outside 'keep.txt'
    [IO.File]::WriteAllText($outsideFile,'outside the lab',[Text.Encoding]::ASCII)
    $outsideHash=Hash $outsideFile
    $junction=Join-Path $lab 'data\reparse-demo'
    New-Item -ItemType Junction -Path $junction -Target $outside | Out-Null
    $null=Run-Kit '00-create-lab.cmd' -NonZero
    $null=Run-Kit '03-backup-demo.cmd' '/apply' -NonZero
    $null=Run-Kit '08-cleanup-demo.cmd' '/confirm' -NonZero
    Assert-Check ((Hash $outsideFile) -eq $outsideHash) 'junction target sentinel preserved'
    $removeJunction='rmdir "'+$junction+'"'
    & $env:ComSpec /d /c $removeJunction
    Assert-Check (!(Test-Path -LiteralPath $junction)) 'test junction removed without recursive deletion'
    Assert-Check (Test-Path -LiteralPath $outsideFile -PathType Leaf) 'junction target remains intact'
    $null=Run-Kit '09-verify-lab.cmd'

    $summary=[pscustomobject]@{passed=$true;checkCount=$checks.Count;checks=$checks;runs=$runs;os=[Environment]::OSVersion.VersionString;kitPath=$kit;labPath=$lab;userProfileChanged=$false;runtime='Native Windows CMD and Windows PowerShell on GitHub Actions'}
    $summary | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputReport -Encoding UTF8
    Write-Host ('ALL PASSED: '+$checks.Count+' checks')
    exit 0
} catch {
    $summary=[pscustomobject]@{passed=$false;checkCount=$checks.Count;checks=$checks;runs=$runs;error=$_.Exception.Message;os=[Environment]::OSVersion.VersionString}
    $summary | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputReport -Encoding UTF8
    Write-Error $_.Exception.Message
    exit 1
}
