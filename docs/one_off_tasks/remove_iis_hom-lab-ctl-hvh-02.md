# One-off: Remove IIS from hom-lab-ctl-hvh-02

**Not Ansible.** Do not add IIS install/remove tasks to any role.

**Why:** Default Windows Server IIS binds `:80` on `192.168.50.158` and blocks the Traefik
portproxy front door. This homelab does not use IIS for any service.

**When:** **Before** any Traefik plan work (parent checklist **P0-remove-iis-hvh-02**; alias **P0-IIS**).

**Host:** `hom-lab-ctl-hvh-02` (WinRM or `ssh hom-lab-ctl-hvh-02-powershell`).

## Apply (PowerShell one-off)

Run on the Windows host. Prefer full removal of the Web Server role if no other sites exist.

```powershell
Import-Module ServerManager -ErrorAction Stop

# Stop sites and release :80 bindings first
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (Get-Module WebAdministration) {
  Stop-Website -Name 'Default Web Site' -ErrorAction SilentlyContinue
  Get-WebBinding -Name 'Default Web Site' -Protocol 'http' -Port 80 -ErrorAction SilentlyContinue |
    ForEach-Object { Remove-WebBinding -Name 'Default Web Site' -BindingInformation $_.bindingInformation }
}

# Remove IIS Web Server feature (one-off cleanup)
$feature = Get-WindowsFeature -Name Web-Server
if ($feature.Installed) {
  Uninstall-WindowsFeature -Name Web-Server -Remove -ErrorAction Stop
}
```

## Verify

On **hom-lab-ctl-hvh-02**:

```powershell
Get-WindowsFeature -Name Web-Server | Select-Object Name, InstallState
Get-Service W3SVC -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType
Get-Website -ErrorAction SilentlyContinue
```

From **mac-dev** (or controller):

```bash
curl -sI http://192.168.50.158/ | head -20
```

**Pass:** `InstallState` is `Available` (not `Installed`); `W3SVC` absent or stopped/disabled;
response headers do **not** contain `Microsoft-IIS`.

Paste raw output into parent plan receipt row **P0-remove-iis-hvh-02**.

## Undo

Manual reinstall only if you later need IIS for an unrelated purpose — out of scope for this repo.
