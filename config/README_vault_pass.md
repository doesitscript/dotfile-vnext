# Vault password setup

Ansible uses a vault password file so encrypted vars can be decrypted without a prompt. This repo is configured to use **`vault_pass.sh`** in the repo root, which reads **`.vault_pass`** (so the real secret stays in one file and the script avoids WSL "Exec format error" when `.vault_pass` has the execute bit set on a Windows mount).

## Commands (what to run)

1. **Create the password file** (repo root):
   ```bash
   echo -n 'YOUR_PASSWORD' > .vault_pass
   ```

2. **Make the wrapper script executable** (required for Ansible to call it). On first run, `fz` may do this for you; otherwise:
   ```bash
   chmod +x vault_pass.sh
   ```

3. **Optional:** Use a custom path by setting in `ansible.cfg`:
   ```ini
   vault_password_file = /path/to/your/vault_pass.sh
   ```

See repo root `vault_pass.sh` for the script; keep `.vault_pass` out of version control.
