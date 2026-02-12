# Local Bootstrap Key Files

Controller SSH public key can come from **either** of these (no order required):

## Option 1: File (non-secret)

- `mac_dev_id_ed25519.pub` – one line, your controller (e.g. Mac) public key.

`bootstrap/local/bootstrap.yml` reads this file when present and installs it into the local bootstrap user's `authorized_keys` on each WSL node. You can generate the key on the Mac (or any controller) anytime and copy the `.pub` contents here, or create the file once and reuse.

## Option 2: Vault (pre-setup, order-free)

Set `vault_controller_ssh_public_key` in `vault/shared.vault.yml` to the full one-line public key (e.g. `ssh-ed25519 AAAA... user@host`). Then run local bootstrap with vault decryption (e.g. `./bin/fz bootstrap --limit server-225-win --ask-vault-pass` or use `.vault_pass`). The play uses the vault value when the file above is missing. This lets you pre-store the key once and run bootstrap on any node without copying files or running the controller first.
