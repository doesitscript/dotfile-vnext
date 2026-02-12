# Controller SSH key (automated)

The **local bootstrap** playbook (`bootstrap/local/bootstrap.yml`) creates and stores the controller SSH key in the project so you never paste keys by hand.

## What happens on first run

1. You run: `./bin/fz bootstrap --limit server-225-win`
2. If **`vault/controller_ssh.vault.yml`** does not exist:
   - Ansible generates an **ed25519** key pair on the node (e.g. desktop-vllm WSL).
   - The **public** key is installed into that node’s `authorized_keys` (so whoever has the private key can SSH in).
   - The **private** and **public** keys are written into **`vault/controller_ssh.vault.yml`** (encrypted with your `.vault_pass`).
   - Temporary key files are removed; only the encrypted vault remains in the repo.
3. If **`vault/controller_ssh.vault.yml`** already exists:
   - Ansible loads it and installs the public key from the vault into the node’s `authorized_keys`.

So: one bootstrap run creates the key and stores it in the project; later runs and other machines use that same key from the vault.

## What is in the vault

- **`vault_controller_ssh_public_key`** – one-line public key (e.g. `ssh-ed25519 AAAA... comment`).
- **`vault_controller_ssh_private_key`** – private key (multi-line PEM).

Both are in **`vault/controller_ssh.vault.yml`** (encrypted). Commit that file; do not commit `.vault_pass`.

## How other setups use it (e.g. Mac as controller)

Any machine that should **SSH into** your WSL (or other nodes) as the “controller” needs the **private** key. The intended way is **Ansible only** (no manual copy/paste):

1. Clone the repo and put `.vault_pass` in the repo root (or use `--ask-vault-pass`).
2. Run a playbook or role on the controller that:
   - Includes `vault/controller_ssh.vault.yml` (with vault password).
   - Uses `vault_controller_ssh_private_key` in a `copy` or `template` task to create e.g. `~/.ssh/id_ed25519_dotfile_controller` (mode 0600).
3. Point SSH at that identity (e.g. in `~/.ssh/config` or Ansible’s `ansible_ssh_private_key_file`).

So: **retrieve** the private key from the project via Ansible; the playbook installs it on the controller. No manual steps.

## Fallback (manual key)

You can still provide the controller public key by hand:

- **File:** `bootstrap/local/files/mac_dev_id_ed25519.pub`
- **Shared vault:** `vault_controller_ssh_public_key` in `vault/shared.vault.yml`

Bootstrap uses the **project** vault `vault/controller_ssh.vault.yml` first; if that file is missing and generation runs, it creates and stores the key there. The file and shared vault are only used when the project controller vault is not used.
