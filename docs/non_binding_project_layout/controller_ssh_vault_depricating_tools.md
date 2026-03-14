# Controller SSH key (automated)

The **server-225 win Ansible bootstrap** creates and stores the controller SSH key in the project and installs it on the controller—all via Ansible, no manual steps.

## 1. On the WSL node (server-225 / desktop-vllm)

Run the local bootstrap (creates the key and stores it in the vault):

- **`./bin/fz bootstrap --limit server-225-win`**  
  Or as part of full server-225 bootstrap: **`.\bin\bootstrap-ansible-local.ps1`** (which runs the above inside WSL).

If **`vault/controller_ssh.vault.yml`** does not exist, Ansible generates an ed25519 key pair, installs the public key into that node’s `authorized_keys`, and writes the private and public keys into **`vault/controller_ssh.vault.yml`** (encrypted). If the vault already exists, it just installs the public key from it.

## 2. On the controller (e.g. Mac)

Install the private key on the machine that will SSH to server-225-wsl—**part of the server-225 bootstrap**, automated:

1. Clone the repo and put `.vault_pass` in the repo root.
2. Run: **`./bin/fz controller-ssh-install`**

That playbook loads `vault/controller_ssh.vault.yml` and writes the private key to **`~/.ssh/id_ed25519_dotfile_controller`** (mode 0600). Then point SSH or Ansible at that identity (e.g. in `~/.ssh/config` or `ansible_ssh_private_key_file` for server-225-wsl).

No manual copy/paste; both “create key on node” and “install key on controller” are in the server-225 win Ansible bootstrap (playbooks + fz commands).

## What is in the vault

- **`vault_controller_ssh_public_key`** – one-line public key.
- **`vault_controller_ssh_private_key`** – private key (multi-line PEM).

Both are in **`vault/controller_ssh.vault.yml`** (encrypted). Commit that file; do not commit `.vault_pass`.

## Fallback (manual key)

You can still provide the controller **public** key by hand instead of generating it:

- **File:** `bootstrap/local/files/mac_dev_id_ed25519.pub`
- **Shared vault:** `vault_controller_ssh_public_key` in `vault/shared.vault.yml`

Bootstrap uses the project vault `vault/controller_ssh.vault.yml` first; if that file is missing and generation runs, it creates and stores the key there. The file and shared vault are only used when the project controller vault is not used.
