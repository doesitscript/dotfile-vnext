# Ansible SSH key (automated)

The ansible SSH key is created and stored in the project so you never paste keys by hand. **No `bootstrap` folder is required**; the key lives in the vault and in `.mgmt/ansible_ssh.pub`.

## Single key pair (never overwrite)

- **One** key pair is used for the whole project: the **ansible** key. The Mac (controller) holds the **private** key; every server (Windows and WSL) has the **same** public key in its `authorized_keys`. Servers do **not** each get their own key pair.
- The key is **created only when** `vault/ansible_ssh.vault.yml` **does not exist**. If the vault already exists, bootstrap **never** generates a new key and **never** overwrites the vault. It only loads the vault and installs the existing public key on the server (or the existing private key on the Mac).
- Writing `.mgmt/ansible_ssh.pub` is idempotent: we write the **same** public key from the vault (or from the just-generated key once). Re-running bootstrap does not create a new key; it only ensures the file and `authorized_keys` are in sync.

## First run: Mac or server

You can run **Mac first** or **server first**; the key is created wherever you run bootstrap when the vault does not exist.

### Mac first (recommended if you develop on Mac)

1. Clone the repo and put **`.vault_pass`** in the repo root (or use `--ask-vault-pass`).
2. Run: **`./bin/fz bootstrap --limit mac-dev`**
3. If **`vault/ansible_ssh.vault.yml`** does not exist:
   - Ansible generates an **ed25519** key pair on the Mac.
   - The **private** key is written to **`~/.ssh/id_ed25519_ansible`** (mode 0600).
   - The **public** key is written to **`.mgmt/ansible_ssh.pub`** (for server bootstrap to use).
   - The **private** and **public** keys are stored in **`vault/ansible_ssh.vault.yml`** (encrypted with `.vault_pass`).
   - Temporary key files are removed; only the encrypted vault and `.mgmt/ansible_ssh.pub` remain.
4. If the vault already exists (e.g. created on server or earlier Mac run):
   - The playbook loads the vault and installs the private key to `~/.ssh/id_ed25519_ansible`.

No manual key creation or copying. When you later run bootstrap on the server (Windows/WSL), it uses `.mgmt/ansible_ssh.pub` or the vault to install the public key into `authorized_keys`.

### Server first (WSL)

1. Run: `./bin/fz bootstrap --limit server-225-win` (or your server limit).
2. If **`vault/ansible_ssh.vault.yml`** does not exist:
   - Ansible generates the key pair on the WSL node, writes the vault, installs the public key into that node's `authorized_keys`, and writes `.mgmt/ansible_ssh.pub`.
3. On the Mac, run **`./bin/fz bootstrap --limit mac-dev`** so the playbook installs the private key from the vault to `~/.ssh/id_ed25519_ansible`.

## What is in the vault

- **`vault_ansible_ssh_public_key`** – one-line public key (e.g. `ssh-ed25519 AAAA... comment`).
- **`vault_ansible_ssh_private_key`** – private key (multi-line PEM).

Both are in **`vault/ansible_ssh.vault.yml`** (encrypted). Commit that file; do not commit `.vault_pass`. The public key is also in **`.mgmt/ansible_ssh.pub`** so server bootstrap can add it to Windows/WSL without decrypting the vault.

## Optional fallback (manual key)

You can provide a separate Mac public key by hand:

- **File:** `bootstrap/mac_ssh_key.pub` (optional; you do **not** need a `bootstrap` folder for the default flow)
- **Shared vault:** `vault_ansible_ssh_public_key` in `vault/shared.vault.yml`

The default, zero-manual path uses **`vault/ansible_ssh.vault.yml`** and **`.mgmt/ansible_ssh.pub`** only.
