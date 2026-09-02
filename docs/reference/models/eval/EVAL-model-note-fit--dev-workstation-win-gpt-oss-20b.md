# EVAL model note fit: dev-workstation-win gpt-oss 20B

Date: 2026-09-02
Host: `dev-workstation-win` (`DESKTOP-C1ACPUM`)
Hardware target: AMD Radeon RX 9060 XT 16GB
Scope: fresh local-model fit review for the Windows Ollama desktop, plus an
honest boundary on what should and should not be promoted into the Codex lane.

Framework: [EVAL-model-note-fit-framework.md](./EVAL-model-note-fit-framework.md)

## Why this note exists

The active Codex desktop implementation lane is still routed as
`qwen2.5-coder:14b@desktop`, but the observed agent behavior was poor: the
model emitted tool-call shaped JSON without completing the tool loop. This note
records a fresh model-fit evaluation for the actual 16GB machine instead of
trusting older repo comments.

## Authority order used

1. Runtime packaging and official vendor/model docs
2. Repo deployment surfaces for what this lab can actually ship
3. Live host probe attempt on the target machine

The repo was used as deployment context, not as the deciding authority on fit.

## Evaluation method

1. Read repo truth for the deploy target:
   `inventory/host_vars/dev-workstation-win.yaml`,
   `playbooks/deploy_dev_workstation_ollama_runtime.yaml`,
   `roles/windows_ollama_runtime/*`.
2. Read gateway truth for what LiteLLM actually publishes today:
   `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`,
   `roles/k3s_litellm_gateway/defaults/main.yml`,
   `roles/k3s_litellm_gateway/tasks/build_helm_values.yml`.
3. Re-check current upstream model fit claims against primary sources:
   OpenAI docs for `gpt-oss-20b`, the OpenAI launch post, Ollama library pages,
   and current Mistral offline-model guidance.
4. Attempt live validation on `dev-workstation-win` before changing routing.

## Deployment surfaces found in repo

- `dev-workstation-win` is the correct deployment target for host-local Ollama.
- The Windows Ollama role can already deploy additional pulled tags through
  `windows_ollama_runtime_models_present`.
- The gateway still publishes the Codex desktop implementation lane as
  `qwen2.5-coder:14b@desktop`.
- The current gateway builder only appends commissioned local routes. It does
  not prove a `gpt-oss-20b@desktop` Codex lane is active.

## Live-validation boundary

Live host validation produced mixed controller evidence:

- `ansible.windows.win_powershell` rejected raw-parameter usage during an early probe.
- The repo SSH helper required `--stdin-file` rather than a direct command.
- This execution environment could not open SSH to `192.168.50.133:22`:
  `ssh: connect to host 192.168.50.133 port 22: Operation not permitted`
- This execution environment could not open WinRM to `192.168.50.133:5985/wsman`:
  `Operation not permitted`
- Separate user-terminal evidence on 2026-09-02 showed:
  - `ping 192.168.50.133` succeeded
  - `ssh 192.168.50.133` reached OpenSSH and prompted for `joshc`'s password

Because of that, this note treats host reachability and `sshd` availability as
supported by user-terminal evidence, while repo-managed key-based access and
WinRM remain unverified from a successful controller session.

## Candidate comparison

| Candidate | Fit on 16GB desktop | Note |
| --- | --- | --- |
| `gpt-oss:20b` | Best fit | OpenAI positions it for local/low-latency use; Ollama lists `14GB`; OpenAI says it can run in `16 GB` memory. |
| `qwen3-coder:30b` | Poor fit | Ollama lists `19GB`; too tight for an honest 16GB recommendation. |
| `qwen3.6:27b` | Poor fit | Ollama lists `18GB`; above the practical desktop target. |
| `devstral:24b` | Weak fit | Current Mistral offline guidance is heavier, and the old small model docs are already deprecated. |
| `qwen2.5-coder:14b` | Rejected for this lane | Smaller and deployable, but the observed Codex behavior was the reason for this fresh review. |

## Decision

Selected model: `gpt-oss:20b`

Fit statement: this is the strongest current local candidate for the
`dev-workstation-win` 16GB-class Ollama host, so it should be kept present on
that machine. This is a host-fit decision first, not an automatic client-lane
decision.

## Non-decision / boundary

Do not automatically swap the Codex desktop implementation lane from
`qwen2.5-coder:14b@desktop` to `gpt-oss:20b` until tool-loop behavior is
validated through the actual LiteLLM/Codex path.

## Next steps

1. Deploy `playbooks/deploy_dev_workstation_ollama_runtime.yaml` to
   `dev-workstation-win` so `gpt-oss:20b` is present on the Windows host.
2. Run a live Ollama probe on the host after deployment:
   `/api/tags`, a short reasoning prompt, and a Codex-style tool-call task.
3. Only if that passes, commission a dedicated LiteLLM client id and route for
   the desktop implementation lane.

## Sources

- OpenAI API docs: https://developers.openai.com/api/docs/models/gpt-oss-20b
- OpenAI launch post: https://openai.com/index/introducing-gpt-oss/
- Ollama `gpt-oss:20b`: https://ollama.com/library/gpt-oss%3A20b
- Ollama `qwen3-coder`: https://ollama.com/library/qwen3-coder
- Ollama `qwen3.6`: https://ollama.com/library/qwen3.6
- Mistral offline models: https://docs.mistral.ai/vibe/code/cli/offline-models
- Mistral `Devstral Small 2` page: https://docs.mistral.ai/models/devstral-small-2-25-12
