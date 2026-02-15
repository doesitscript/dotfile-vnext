# OpenSSH host keys for Windows (server-225)

The **Mac is the source of truth and controller** for OpenSSH on Windows: host keys are generated on the Mac and deployed via Ansible. The Ansible SSH key lives only at `~/.ssh/id_ed25519_ansible` on the Mac; playbooks read it from the execution node at run time. No key files in the repo.

OpenSSH server host keys are **generated on the Mac** (control node), stored in **Ansible vault**, and **deployed to Windows** by the bootstrap playbook. Login keys in `authorized_keys` on Windows come from the execution node’s `~/.ssh/id_ed25519_ansible.pub` (deployed when you run bootstrap from the Mac) or optionally from `bootstrap/id_ed25519_ansible.pub` (deprecated: `bootstrap/mac_ssh_key.pub`). No manual copy.

## Flow (fully automated)

1. **Generate keys (Mac):** Run from repo root on the control node. Key generation is done entirely by Ansible (`community.crypto.openssh_keypair`); no shell script.
   ```bash
   ./bin/fz bootstrap-openssh-host-keys
   ```
   Or: `ansible-playbook playbooks/bootstrap_openssh_host_keys.yaml`  
   Add `--force` or `-e force=true` to regenerate.  
   This creates keys under `bootstrap/openssh_host_keys/`, then **slurps them into `vault/openssh_host_keys.vault.yml`** (encrypted). The vault file is committed; the raw key files in this directory remain gitignored.

2. **Deploy to Windows:** From the Mac:
   ```bash
   ./bin/fz bootstrap --limit server-225-win
   ```
   The bootstrap Windows playbook loads the host keys from vault and writes them to `C:\ProgramData\ssh` on the Windows host. Use `--ask-vault-pass` or `ANSIBLE_VAULT_PASSWORD_FILE` (e.g. `.vault_pass`) when the vault exists.

## Optional: local keys on Windows

If you have key files in this directory on the Windows machine, `bin\bootstrap-local.ps1` will still install them into `C:\ProgramData\ssh`. The canonical, automated path is vault → playbook; the script is a fallback for local-only use.

## Required key files (names must match)

- `ssh_host_ed25519_key` and `ssh_host_ed25519_key.pub`
- `ssh_host_rsa_key` and `ssh_host_rsa_key.pub`

Optional: `ssh_host_ecdsa_key` and `ssh_host_ecdsa_key.pub` (not in vault by default).
