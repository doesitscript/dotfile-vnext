# Ansible SSH key (automated)

The **local bootstrap** playbook (`playbooks/bootstrap_local.yml`) creates and stores the ansible SSH key in the project so you never paste keys by hand.

## What happens on first run

1. You run: `./bin/fz bootstrap --limit server-225-win`
2. If **`vault/ansible_ssh.vault.yml`** does not exist:
   - Ansible generates an **ed25519** key pair on the node (e.g. desktop-vllm WSL).
   - The **public** key is installed into that node's `authorized_keys` (so the Mac can SSH in).
   - The **private** and **public** keys are written into **`vault/ansible_ssh.vault.yml`** (encrypted with your `.vault_pass`).
   - Temporary key files are removed; only the encrypted vault remains in the repo.
3. If **`vault/ansible_ssh.vault.yml`** already exists:
   - Ansible loads it and installs the public key from the vault into the node's `authorized_keys`.

So: one bootstrap run creates the key and stores it in the project; later runs and the Mac use that same key from the vault.

## What is in the vault

- **`vault_ansible_ssh_public_key`** – one-line public key (e.g. `ssh-ed25519 AAAA... comment`).
- **`vault_ansible_ssh_private_key`** – private key (multi-line PEM).

Both are in **`vault/ansible_ssh.vault.yml`** (encrypted). Commit that file; do not commit `.vault_pass`.

## How the Mac uses it

The Mac (where you run Ansible) needs the **private** key to SSH into WSL nodes:

1. Clone the repo and put `.vault_pass` in the repo root (or use `--ask-vault-pass`).
2. Run `./bin/fz bootstrap --limit mac-dev` which:
   - Includes `vault/ansible_ssh.vault.yml` (with vault password).
   - Uses `vault_ansible_ssh_private_key` to create `~/.ssh/id_ed25519_ansible` (mode 0600).

So: **retrieve** the private key from the project via Ansible; the playbook installs it on the Mac. No manual steps.

## Fallback (manual key)

You can still provide the Mac public key by hand:

- **File:** `bootstrap/mac_ssh_key.pub`
- **Shared vault:** `vault_ansible_ssh_public_key` in `vault/shared.vault.yml`

Bootstrap uses the **project** vault `vault/ansible_ssh.vault.yml` first; if that file is missing and generation runs, it creates and stores the key there. The file and shared vault are only used when the project ansible vault is not used.
