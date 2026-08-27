# One-off: Remove IIS from HOM-LAB-HVH-02

**Superseded by Ansible** — IIS removal is part of `roles/windows_base` via `roles/windows_iis`
(`windows_iis_state: absent` in `group_vars/windows_server_2025.yml`).

Run baseline or tag only:

```bash
ansible-playbook playbooks/windows_base.yml -i inventory/inventory.yaml --tags windows_iis
```

This doc is retained for historical plan receipts only.

**Why:** Default Windows Server IIS binds `:80` and blocks portproxy front doors.
This homelab does not use IIS for any service.

**When:** Before Traefik / portproxy work on any Windows Server hypervisor.

**Hosts:** All `windows_server_2025` hosts (HVH-01, HVH-02).

## Apply (Ansible — preferred)

```bash
ansible-playbook playbooks/windows_base.yml -i inventory/inventory.yaml --tags windows_iis
```

## Apply (legacy PowerShell one-off)

Run on the Windows host only if Ansible is unavailable:

```powershell
Import-Module ServerManager -ErrorAction Stop
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (Get-Module WebAdministration) {
  Stop-Website -Name 'Default Web Site' -ErrorAction SilentlyContinue
  Get-WebBinding -Name 'Default Web Site' -Protocol 'http' -Port 80 -ErrorAction SilentlyContinue |
    ForEach-Object { Remove-WebBinding -Name 'Default Web Site' -BindingInformation $_.bindingInformation }
}
$feature = Get-WindowsFeature -Name Web-Server
if ($feature.Installed) {
  Uninstall-WindowsFeature -Name Web-Server -Remove -ErrorAction Stop
}
```

## Verify

```bash
curl -sI http://192.168.50.158/ | head -20
curl -sI http://ollama-hvh01.hom.lab/ | head -20
```

**Pass:** No `Microsoft-IIS` in response headers; `Get-WindowsFeature Web-Server` shows `Available`.
