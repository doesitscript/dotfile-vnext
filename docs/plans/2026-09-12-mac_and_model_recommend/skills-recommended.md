# Skills recommended for this workflow

Goal: go from **(1) roles/features needed** + **(2) free infrastructure** →
research → recommendation packet → Ansible apply, without reinventing the path
each time.

## Skill chain (use in order)

```text
User: roles + free hosts/GPUs
        │
        ▼
continue-ide-model-lane-recommend     ← NEW (this packet)
        │  produces recommendation matrix + plan packet notes
        ▼
homelab-ansible-first-entry           ← existing
        │  routes mutate/install
        ├── windows_ollama / HF weights doors as needed
        ▼
(apply) windows_ollama_runtime + k3s_litellm_gateway + continue_ide
        │
        ▼
continue-ide-model-lane-verify        ← NEW (smoke decode + probes)
```

| Skill | Repo | Job |
| --- | --- | --- |
| `continue-ide-model-lane-recommend` | dotfile-vnext project | Research + place models for Continue roles given free infra |
| `continue-ide-model-lane-verify` | dotfile-vnext project | Decode and re-run embed/FIM/chat smokes; update plan evidence |
| `homelab-ansible-first-entry` | existing | Gate all pulls/routes/config applies |
| `hf-model-weight-lifecycle` | existing | Only when HF weight trees (not Ollama tags) are required |

Authority copies of role cards live in this plan folder and are mirrored under
the recommend skill `references/` so agents load them without hunting the plan.

## Copy-paste prompt

Canonical copy lives in inventory intake YAML as
`ai_cli_model_lane_intake.prompt_snippet`
(`inventory/group_vars/all/ai_cli_apps.yml`). Same text:

```text
Use skill continue-ide-model-lane-recommend with:
  roles: [chat, edit, apply, autocomplete, embed]
  free_infra: <hosts, GPUs, VRAM, runtimes>
  client: mac-dev Continue via LiteLLM
Then use skill homelab-ansible-first-entry to apply, then continue-ide-model-lane-verify.
```

Dependents + ASCII cogs: `inventory/group_vars/all/ai_cli_apps-INTAKE.md`,
`inventory/group_vars/all/ai_cli_apps-INFRA-COGS.md`.
