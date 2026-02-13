# OpenSSH on Windows — Configuration Checklist

The keys used for login are **from your Mac** (the machine you SSH from). Put your Mac’s public key in the Windows `authorized_keys` file so you can sign in.

---

## Checklist

| File / Entity | Path | Required state |
|--------------|------|----------------|
| Global config | `C:\ProgramData\ssh\sshd_config` | Match Group administrators block commented out so user-specific keys are used. Do **not** set `Port` in the global config. |
| User folder | `C:\Users\josh\.ssh` | Permissions restricted to `josh` and SYSTEM only. |
| Key list | `C:\Users\josh\.ssh\authorized_keys` | Contains your **Mac’s** public key (`ssh-rsa...` or `ssh-ed25519...`). |

---

## Step 1: Fix the global configuration

Open `C:\ProgramData\ssh\sshd_config` as Administrator and ensure these lines at the bottom are **commented out** (add a `#`):

```text
# Match Group administrators
#        AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

If they stay active, the server will ignore your user folder and you won’t be able to use `C:\Users\josh\.ssh\authorized_keys`.

Do **not** add or change `Port` in the global config; leave the default or let other tooling manage it. The firewall rule for OpenSSH uses the port from **host_vars**: `win_ssh_port` in `inventory/host_vars/<node>-win.yaml` (default 22). That value is set when you run `.\bin\bootstrap-local.ps1` on the Windows box and is used by both the local script and the Mac-run bootstrap playbook.

---

## Step 2: “Purge and rebuild” script

Run this in an elevated PowerShell window. It removes the existing `.ssh` directory (to clear bad permissions) and recreates it with correct permissions.

```powershell
$sshPath = "C:\Users\josh\.ssh"
$keyFile = "$sshPath\authorized_keys"

# 1. Remove the old directory if it exists
if (Test-Path $sshPath) {
    Remove-Item -Recurse -Force $sshPath
}

# 2. Recreate the directory
New-Item -ItemType Directory -Path $sshPath

# 3. Create the empty authorized_keys file
New-Item -ItemType File -Path $keyFile

# 4. Strip inheritance (makes it private)
icacls $sshPath /inheritance:r

# 5. Grant ONLY josh and SYSTEM full control
icacls $sshPath /grant:r "${env:USERNAME}:(OI)(CI)F"
icacls $sshPath /grant:r "SYSTEM:(OI)(CI)F"

Write-Host "Folder recreated. Paste your Mac's public key into: $keyFile" -ForegroundColor Cyan
```

---

## Step 3: Populate and restart

1. **Paste your Mac’s public key**  
   Open `C:\Users\josh\.ssh\authorized_keys` in Notepad and paste your **Mac’s** public key (the one you use to SSH from the Mac). Save and close.

2. **Restart the service** (so `sshd_config` changes take effect):

   ```powershell
   Restart-Service sshd
   ```
