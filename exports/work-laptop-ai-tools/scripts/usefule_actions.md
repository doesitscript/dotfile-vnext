# Useful actions

## Recent error and assessment

Recent convergence was blocked by the packet's expected-local-hostname safety
gate when run outside the commissioned work laptop. Run the packet on the
commissioned laptop, or explicitly request the optional packet-side
hydrate-and-apply task in `work-laptop-day2-apply`. Do not bypass the hostname
assertion.

## Highest-upstream configuration points

| Surface | Highest-upstream entry | Downstream surfaces |
| --- | --- | --- |
| Model catalog / client SSOT | `dotfile-vnext/inventory/group_vars/all/ai_cli_apps.yml` | Continue, Cline, Codex, OpenCode, Kilo exports |
| LiteLLM gateway | `dotfile-vnext/roles/k3s_litellm_gateway/defaults/main.yml` and `tasks/build_helm_values.yml` | Helm values, deployed LiteLLM route, client API |
| vLLM | `dotfile-vnext/inventory/host_vars/hom-lab-ctl-k3s-02.yaml` | vLLM runtime and served model |
| Ollama | commissioned host vars and the corresponding LiteLLM route in `build_helm_values.yml` | Ollama service and client route |

## Standard handoff commands

```bash
cd /Users/joshc/develop/dotfile-vnext
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/validate_export_contract.py
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py

cd /Users/joshc/develop/work-laptop-ai-tools
git add -A
git diff --cached --check
git commit -m "Prepare work laptop packet handoff"
git push origin HEAD
```
