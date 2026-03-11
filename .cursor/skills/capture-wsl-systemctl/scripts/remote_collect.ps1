param(
    [string]$Distro = "Ubuntu-24.04"
)

function wslrun {
    param([string]$cmd)
    wsl -d $Distro -- bash -c $cmd 2>&1
}

$ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Output "=== systemctl capture ==="
Write-Output "wsl distro: $Distro"
Write-Output "time:       $ts"
Write-Output ""

Write-Output "--- systemctl status (top-level) ---"
wslrun "systemctl status --no-pager; true"
Write-Output ""

Write-Output "--- systemctl list-units --type=service --all ---"
wslrun "systemctl list-units --type=service --all --no-pager"
Write-Output ""

Write-Output "--- systemctl list-units --failed ---"
wslrun "systemctl list-units --failed --no-pager"
Write-Output ""

Write-Output "--- keepwsl.service status ---"
wslrun "systemctl status keepwsl.service --no-pager; true"
Write-Output ""

Write-Output "--- journalctl -b (last 150 lines) ---"
wslrun "journalctl -b --no-pager -n 150"
