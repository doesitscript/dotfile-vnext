# Redirect — desktop-only WSL Ansible chain (moved from bin/).
$desktopScript = Join-Path $PSScriptRoot 'desktop\bootstrap-ansible-local.ps1'
if (-not (Test-Path $desktopScript)) {
    Write-Error "Desktop WSL Ansible bootstrap not found: $desktopScript"
    exit 1
}
Write-Host '[INFO] Server lanes must not chain through WSL. Forwarding to bin/desktop/bootstrap-ansible-local.ps1' -ForegroundColor Yellow
& $desktopScript @args
exit $LASTEXITCODE
