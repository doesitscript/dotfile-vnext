# huggingface_cli_mac

Install the Hugging Face Hub CLI (`hf`) on macOS for **searching and
downloading** models — without requiring a local inference GUI.

This is the practical Monterey/Intel substitute when apps like ToolPiper
(macOS 26 + Apple Silicon) or LM Studio (arm64) cannot run on the controller.

## Why this role

| App | Why not on this Mac |
| --- | --- |
| ToolPiper | Requires **macOS 26+** and **Apple Silicon** |
| LM Studio | Homebrew cask requires **arm64** |
| Current Ollama GUI cask | Requires Sonoma 14+ (we pinned an older GUI separately) |

`hf` works on Monterey x86_64 and can write into the HVH public share mount
(`~/HomelabSMB/hvh-01-public/models/huggingface` by default).

## Vault (required HF token)

Same required-key shape as Morph MCP. Same vault file and key as
`k3s_vllm_runtime`: `vault_hf_token` in `vault/shared.vault.yml`.

| Condition | Behavior |
| --- | --- |
| Vault file missing | `present` fails |
| `vault_hf_token` empty or `REPLACE_ME` | `present` fails |
| `vault_hf_token` set | `hf auth login --token` writes the local CLI store, and the env file exports `HF_TOKEN` (`0600`) |
| `-e huggingface_cli_mac_hf_token=...` | Overrides vault for this run |

The token file is `~/.cache/huggingface/token`. It is not written under
`HF_HOME` on the public share. See `docs/reference/controller-cli-vault-creds.md`.

## Lifecycle

| State | Effect |
| --- | --- |
| `present` | `pipx install huggingface_hub`, vault login, HF env file |
| `absent` | `pipx uninstall` + remove managed env files |

## Apply / Verify / Undo / Change class

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags huggingface_cli_mac --limit mac-dev
```

- **Verify:** `env -u HF_TOKEN -u HUGGINGFACE_HUB_TOKEN hf auth whoami` (uses the CLI store, not the shell)
- **Download example:** `hf download Qwen/Qwen2.5-Coder-1.5B-Instruct --local-dir "$HF_HOME/Qwen--Qwen2.5-Coder-1.5B-Instruct"`
- **Undo:** `-e huggingface_cli_mac_state=absent`
- **Change class:** idempotent controller-local package install

Catalog weight lifecycle on HVH-01 remains `hf-model-weight-lifecycle` /
Windows `huggingface_hub` role — this role is the Mac operator client.
