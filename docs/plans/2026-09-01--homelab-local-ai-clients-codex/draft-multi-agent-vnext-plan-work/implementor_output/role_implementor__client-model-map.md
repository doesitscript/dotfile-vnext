<!-- Concurrent-work note: Codex owns this client/model map; keep it separate from concurrent Cursor/Kilo changes. -->

# Local AI Client Model Map

**Implementation author:** Codex (OpenAI), for the Codex CLI profiles and the
shared Codex validation implementation summarized here.

**Scope:** models explicitly configured by the local-client implementation.
Routes use the LiteLLM `model@host` contract at `http://litellm.hom.lab/v1`.
This is a map of configuration, not an approval claim for every listed profile.

## VS Code-Compatible Extension: Continue

Continue is the configured VS Code-compatible extension (also used from
Cursor). Its generated `~/.continue/config.yaml` has these selected lanes:

| Continue role | LiteLLM route | Hosted model | Status |
| --- | --- | --- | --- |
| Chat / quality coding | `qwen2.5-coder-32b@k3s02-vllm` | `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` on RTX 5090 vLLM | Selected and validated |
| Edit / apply | `qwen2.5-coder-7b@desktop` | Qwen2.5-Coder 7B Instruct on desktop Ollama | Selected and validated |
| Inline autocomplete / FIM | `qwen2.5-coder-1.5b@hvh01` | Qwen2.5-Coder 1.5B Instruct on HVH-01 Ollama | Selected and validated |

```text
dotfile-vnext/                         VS Code-compatible Continue configuration
├── inventory/host_vars/mac-dev.yaml   enables continue_ide on mac-dev
├── roles/continue_ide/
│   ├── defaults/main.yml               defines the three model routes and roles
│   ├── templates/config.yaml.j2        renders ~/.continue/config.yaml
│   └── tasks/mac.yml                   deploys the generated configuration
└── docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/
    └── README.md                       deployment and extension-faithful probe receipt
```

## Codex CLI: Explicit Terminal Profiles

`~/bin/codex-homelab <profile>` selects one profile at a time. These are not a
fallback group and do not configure IDE autocomplete.

| Terminal / profile | LiteLLM route | Intended work | Current qualification |
| --- | --- | --- | --- |
| `codex-homelab deep` / `local-deep` | `qwen2.5-coder-32b@k3s02-vllm` | Repository reasoning and implementation | **Approved for response/reasoning.** Exact-output CLI contract passes; shell tool loop is not approved. |
| `codex-homelab fast` / `local-fast` | `qwen2.5-coder-7b@desktop` | Short coding questions | Experimental: transport works, but an exact-output contract produced tool-shaped JSON. |
| `codex-homelab tools` / `local-tools` | `ministral-3-8b@desktop` | Alternate local tool candidate | Experimental: full-context Codex test timed out; not for unattended tool use. |
| `codex --profile hom-lab` / `hom-lab` | `qwen2.5-coder-7b@desktop` | Compatibility profile | Same 7B route as `local-fast`; retained for the original simple profile installation path. |

Not configured: Gemini (no credentialed LiteLLM Responses route), Qwen3 4B
(short utility candidate only), Qwen3-Coder, Devstral, and the rejected 14B
vLLM route.

```text
dotfile-vnext/                         Codex CLI configuration and evidence
└── docs/plans/2026-09-01--homelab-local-ai-clients-codex/
    ├── templates/
    │   ├── local-deep.config.toml      deep -> Qwen2.5-Coder 32B AWQ
    │   ├── local-fast.config.toml      fast -> Qwen2.5-Coder 7B
    │   ├── local-tools.config.toml     tools -> Ministral 3 8B
    │   └── hom-lab.config.toml         compatibility -> Qwen2.5-Coder 7B
    ├── scripts/codex_homelab.sh        profile-selecting launcher
    ├── codex-execution-receipt.md      live CLI evidence and limitations
    ├── limitations-and-follow-up.md    approval boundaries
    └── codex-model-research-matrix.md  researched but unselected candidates
```

```text
global-skills/                         Codex CLI validation implementation
└── skills/validation/
    ├── homelab-codex-cli-model-pytest/
    │   ├── SKILL.md                    CLI validation entry point
    │   └── scripts/run_codex_cli_model_pytest.py
    └── homelab-litellm-model-lane-pytest/
        ├── references/codex-cli-default-profiles.yml
        ├── references/codex-cli-tool-loop-candidate.yml
        ├── lib/codex_cli_manifest.py
        ├── lib/codex_cli_probe.py
        └── tests/
            ├── test_codex_cli_live.py
            └── test_codex_cli_probe.py
```

## Current Boundary

The 32B model is deliberately shared by Continue quality chat and Codex deep
reasoning, but it is one resident 5090 vLLM service, not a second simultaneous
large model. Passing response contracts prove the selected route works for
chat/reasoning; a raw `exec` JSON object is recorded as a failed Codex tool-loop
contract, not treated as tool execution.
