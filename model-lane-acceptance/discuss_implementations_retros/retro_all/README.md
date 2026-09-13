# Retro: Qwen3-Coder-30B (all surfaces)

Filled implementation / day-2 discussion captures for this lane live under
dated packet folders. The empty form is still
[`../retro-capture.template.yml`](../retro-capture.template.yml) — do not treat
filled YAMLs as live Ansible inventory.

## Authorities

| Surface | Path |
| --- | --- |
| Client model ids | `roles/k3s_litellm_gateway/defaults/main/model_client_ids.yml` |
| Runner + LiteLLM host backends | `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` |
| Commissioned client SSOT | `inventory/group_vars/all/ai_cli_apps.yml` |

Optional fuller day-2 scaffold:
`inventory/group_vars/all/ai_cli_client_day2-INPUTS.template.yml`

## Packets

| Folder | Focus |
| --- | --- |
| [`2026-09-12-qwen3-coder-config-evaluation/`](2026-09-12-qwen3-coder-config-evaluation/) | Continue overflow + dual embed; filled actors YAML, proposal, before/after SVGs |

## First use (new captures)

Focus **Continue** client inputs. Leave Cline / Codex as `status: reserved`
until a later pass. Copy the template into a new dated folder under this
directory when starting another retro.
