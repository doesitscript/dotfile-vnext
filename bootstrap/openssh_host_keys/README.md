# OpenSSH host keys for Windows (server-225)

Place **OpenSSH server host keys** here so `bin\bootstrap-local.ps1` can install them idempotently on the Windows OpenSSH server (`C:\ProgramData\ssh`).

**Required files (names must match):**

- `ssh_host_ed25519_key` and `ssh_host_ed25519_key.pub`
- `ssh_host_rsa_key` and `ssh_host_rsa_key.pub`
- (optional) `ssh_host_ecdsa_key` and `ssh_host_ecdsa_key.pub`

## Generating keys (no manual steps)

Run **on the Mac** (control node) from the repo root. Do not run `ssh-keygen` by hand.

**Option 1 – Bootstrap command (recommended):**

```bash
./bin/fz bootstrap-openssh-host-keys
```

Add `--force` to regenerate existing keys.

**Option 2 – Ansible playbook:**

```bash
ansible-playbook playbooks/bootstrap_openssh_host_keys.yaml
# Regenerate: ansible-playbook playbooks/bootstrap_openssh_host_keys.yaml -e force=true
```

Both create keys in this directory (idempotent unless `--force` / `force=true`). The directory is gitignored so private keys are not committed.

Then sync this folder (or repo) to the Windows machine and run `.\bin\bootstrap-local.ps1` there; it will install these keys into `C:\ProgramData\ssh` every run.
