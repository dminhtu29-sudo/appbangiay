<#
Clean-build script for Flutter projects on Windows.

Usage:
  .\scripts\clean-build.ps1                # delete common temp folders and stop flutter/dart processes
  .\scripts\clean-build.ps1 -RunFlutterClean # also run `flutter clean` after deleting

What the script does:
- Stops common Dart/Flutter processes (dart, flutter, flutter_tester)
- Resets file attributes to Normal for files under the target folders
- Removes common build and ephemeral folders that often get file locks
- Optionally runs `flutter clean` (requires flutter on PATH)

Be careful: this permanently deletes the listed directories (build, .dart_tool, ephemeral folders).
#>
param(
    [switch]$RunFlutterClean
)

Set-StrictMode -Version Latest

# Determine project root (parent of scripts folder)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot
Write-Host "Project root:" $ProjectRoot

# Processes to stop (ignore errors if not running)
$procNames = @('dart','flutter','flutter_tester','pub')
Write-Host "Stopping common Flutter/Dart processes (if any):" -ForegroundColor Cyan
foreach ($n in $procNames) {
    try {
        $procs = Get-Process -Name $n -ErrorAction SilentlyContinue
        foreach ($p in $procs) {
            Write-Host "Stopping process: $($p.ProcessName) Id=$($p.Id)" -ForegroundColor Yellow
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # ignore
    }
}

# Paths to attempt to remove (relative to project root)
$targets = @(
    'build\\unit_test_assets',
    'build\\flutter_assets',
    'build',
    '.dart_tool',
    'ios\\Flutter\\ephemeral',
    'macos\\Flutter\\ephemeral',
    'linux\\flutter\\ephemeral',
    'windows\\flutter\\ephemeral'
)

foreach ($t in $targets) {
    $full = Join-Path $ProjectRoot $t
    if (Test-Path $full) {
        Write-Host "Found: $t -> attempting to clear attributes and remove..." -ForegroundColor Cyan
        try {
            # Clear ReadOnly / Hidden flags where possible
            Get-ChildItem -Path $full -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                try { $_.Attributes = 'Normal' } catch { }
            }
            Remove-Item -LiteralPath $full -Recurse -Force -ErrorAction Stop
            Write-Host ("Deleted: {0}" -f $t) -ForegroundColor Green
        } catch {
            Write-Host ("Failed to delete {0}: {1}" -f $t, $_.Exception.Message) -ForegroundColor Red
            Write-Host 'Listing contents and attributes for debugging:' -ForegroundColor Yellow
            try {
                Get-ChildItem -Path $full -Recurse -Force | Select-Object FullName,Attributes | Format-Table -AutoSize
            } catch { Write-Host "Unable to list contents." }
        }
    } else {
        Write-Host "Not found: $t" -ForegroundColor DarkGray
    }
}

if ($RunFlutterClean) {
    Write-Host "Running 'flutter clean'..." -ForegroundColor Cyan
    try {
        flutter clean
    } catch {
        Write-Host "Failed to run 'flutter clean'. Make sure 'flutter' is on PATH and you have permissions." -ForegroundColor Red
    }
}

Write-Host "Done. You can now run your tests or flutter run." -ForegroundColor Green
