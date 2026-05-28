# Redirect — desktop-only WSL bootstrap (moved from bin/).
$desktopScript = Join-Path $PSScriptRoot 'desktop\bootstrap-wsl.ps1'
if (-not (Test-Path $desktopScript)) {
    Write-Error "Desktop WSL bootstrap not found: $desktopScript"
    exit 1
}
Write-Host '[INFO] Server lanes must not use WSL automation. Forwarding to bin/desktop/bootstrap-wsl.ps1' -ForegroundColor Yellow
& $desktopScript @args
exit $LASTEXITCODE
