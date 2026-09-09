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

## Vault (optional HF token)

Same pattern as Context7 MCP / `k3s_vllm_runtime`: load
`vault_hf_token` from `vault/shared.vault.yml` when present.

| Condition | Behavior |
| --- | --- |
| Vault file missing | Install continues; no `HF_TOKEN` in env file |
| `vault_hf_token` empty | Install continues; unauthenticated Hub access |
| `vault_hf_token` set | Env file exports `HF_TOKEN` + `HUGGINGFACE_HUB_TOKEN` (`0600`) |
| `-e huggingface_cli_mac_hf_token=...` | Overrides vault for this run |

Empty token never fails the role (unlike Morph MCP, which requires a key).

## Lifecycle

| State | Effect |
| --- | --- |
| `present` | `pipx install huggingface_hub` + HF_HOME env (+ token when set) |
| `absent` | `pipx uninstall` + remove managed env files |

## Apply / Verify / Undo / Change class

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags huggingface_cli_mac --limit mac-dev
```

- **Verify:** `hf version`; with token, `source ~/.config/homelab/huggingface_cli_mac.env && hf auth whoami`
- **Download example:** `hf download Qwen/Qwen2.5-Coder-1.5B-Instruct --local-dir "$HF_HOME/Qwen--Qwen2.5-Coder-1.5B-Instruct"`
- **Undo:** `-e huggingface_cli_mac_state=absent`
- **Change class:** idempotent controller-local package install

Catalog weight lifecycle on HVH-01 remains `hf-model-weight-lifecycle` /
Windows `huggingface_hub` role — this role is the Mac operator client.
