# Vault password file

Playbooks and `ansible-vault` need a vault password to decrypt vault files. Create a **vault password file** so you are not prompted every time.

## Recommended: repo root (same from WSL or Windows)

Create a file named **`.vault_pass`** in the **repo root** (this project’s root directory):

- **From WSL:** e.g. `/mnt/d/develop/dotfile-vnext/.vault_pass`
- **From Windows:** e.g. `D:\develop\dotfile-vnext\.vault_pass`

Put one line in it: your vault password (no trailing newline if you prefer, or one newline).

- `.vault_pass` is in `.gitignore` and in the git role’s global ignore, so it will not be committed or zipped by accident.
- `ansible.cfg` uses `vault_password_file = vault_pass.sh`, a script that reads `.vault_pass` (avoids WSL "Exec format error" when `.vault_pass` is executable on a Windows mount). Run from repo root so the same path works from WSL and Windows. **Do not** pass `--vault-password-file` with an absolute Windows path when inside WSL; let `ansible.cfg` handle it.

## Optional: default location (e.g. Windows home)

If you prefer to keep the password file outside the repo (e.g. in your Windows home directory), you can:

1. Create the file there (e.g. in WSL: `/mnt/c/Users/YOUR_USERNAME/.vault_pass`).
2. Add that path (one line) to **`config/vault_pass_suggested_path.txt`** in this repo. Scripts will suggest that path when `.vault_pass` is missing.
3. Either symlink or copy that file to repo root as `.vault_pass`, or run Ansible with `--vault-password-file /mnt/c/Users/YOUR_USERNAME/.vault_pass` (or set it in `ansible.cfg` to that path if you always use it).

If `.vault_pass` is missing and you have not passed `--ask-vault-pass` or `--vault-password-file`, the scripts will ask you to create the file and will suggest the path from `config/vault_pass_suggested_path.txt` if it exists.

## Commands (what to run)

| What to do | Command |
|------------|---------|
| Create the vault password file (one-time) | Put your vault password as a single line in repo root: `echo -n 'YOUR_PASSWORD' > .vault_pass` (WSL) or create `D:\develop\dotfile-vnext\.vault_pass` in an editor (Windows). |
| Fix "Exec format error" or script not executable | From WSL: `chmod +x vault_pass.sh` — makes the wrapper script executable so Ansible can run it to read `.vault_pass`. |
| Use a custom vault password file for one run | `./bin/fz bootstrap --limit server-225-win --vault-password-file /path/to/file` or `--ask-vault-pass` to be prompted. |
