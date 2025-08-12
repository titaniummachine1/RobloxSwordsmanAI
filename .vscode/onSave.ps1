$ErrorActionPreference = 'SilentlyContinue'
$repoRoot = Resolve-Path "$PSScriptRoot\.."
$rojoExe = Join-Path $repoRoot ".aftman/bin/rojo.exe"

if (-not (Test-Path $rojoExe)) {
    # Fallback to PATH if rojo installed globally
    $rojoExe = "rojo"
}

function Ensure-RojoServe {
    $running = Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'rojo*.exe' -and $_.CommandLine -match 'serve' }
    if (-not $running) {
        Start-Process -FilePath $rojoExe -ArgumentList "serve" -WorkingDirectory $repoRoot -WindowStyle Minimized
    }
}

Ensure-RojoServe


