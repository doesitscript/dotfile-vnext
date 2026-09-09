# Controller CLI vault credentials

How a controller CLI gets a vault-stored credential. First client:
`roles/huggingface_cli_mac` and `vault_hf_token`.

## Default

`present` requires the key. A missing or empty token fails the role. Do not
leave the CLI anonymous and document a later login.

## Steps

1. Put the secret in `vault/shared.vault.yml` under a `vault_*` key.
2. Role `tasks/load_vault.yml` asserts the file exists and the key is not
   empty or `REPLACE_ME`. Same shape as `roles/mcp_servers/morph`.
3. Role writes the tool's own credential store, not only a shell export.
4. Keep the token off shared mounts. For Hugging Face, `HF_HOME` may point at
   the HVH-01 public `models/huggingface` folder, but `HF_TOKEN_PATH` stays
   `~/.cache/huggingface/token`.
5. Verify with the inherited token unset (`HF_TOKEN` and
   `HUGGINGFACE_HUB_TOKEN` empty) so the check proves the store.

## Hugging Face CLI

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags huggingface_cli_mac --limit mac-dev
```

```bash
env -u HF_TOKEN -u HUGGINGFACE_HUB_TOKEN hf auth whoami
```

Env file `~/.config/homelab/huggingface_cli_mac.env` is extra, for scripts.
The CLI login is the default path.
