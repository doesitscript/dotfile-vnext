---
deprecated: true
deprecating_reason: WSL scope reform 2026-05-28 — server paths must not use WSL
coordinator_review: pending
---

# Ansible SSH key (canonical location only)

The Ansible SSH key has a **single source of truth**: the execution node’s `~/.ssh/` directory. The key is **never** copied into the repo.

## Single key pair

- **One** key pair is used for the project: **`~/.ssh/id_ed25519_ansible`** (and **`.pub`**) on the host where Ansible runs (the **execution node**, e.g. your Mac).
- The key is **created only when it does not exist**. Mac bootstrap (`./bin/fz bootstrap --limit mac-dev`) ensures `~/.ssh` exists and generates the key there if missing. It does **not** write the key into the repo (no `.mgmt/`, no vault for this key).
- Windows and WSL bootstrap playbooks **read the public key from the execution node at run time** (delegate to `execution_nodes`, read `~/.ssh/id_ed25519_ansible.pub`) and add it to `authorized_keys` on the target. No repo path, no duplication.

## Execution node

- The **execution node** is defined in inventory (e.g. `execution_nodes` with `mac-dev`, `ansible_connection: local`). That host is where `ansible-playbook` runs and where the key lives.
- Delegation to `groups['execution_nodes'][0]` is used when a playbook needs the public key; the lookup runs on the controller, which is the execution node when you run from the Mac.

## First run (Mac)

1. Put **`.vault_pass`** in the repo root if you use vault for other secrets (e.g. OpenSSH host keys). Not required for the Ansible SSH key.
2. Run: **`./bin/fz bootstrap --limit mac-dev`**
3. The playbook ensures **`~/.ssh/id_ed25519_ansible`** exists; if not, it generates an ed25519 key pair there. Nothing is written into the repo.
4. Run **`./bin/fz bootstrap --limit hom-lab-ctl-hvh-02`** (and similar) from the Mac to deploy that public key to Windows/WSL. The playbook reads from the execution node’s `~/.ssh/id_ed25519_ansible.pub`.

## Optional: bootstrap key file (local script only)

If you run `bin\bootstrap-local.ps1` on Windows without running the playbook from the Mac first, you can place the controller public key in **`bootstrap/id_ed25519_ansible.pub`**. The script will add it to Windows `authorized_keys`. Deprecated: **`bootstrap/mac_ssh_key.pub`** is still supported as a fallback. The primary, automated path is: key on execution node → read at run time → deploy by Ansible.
