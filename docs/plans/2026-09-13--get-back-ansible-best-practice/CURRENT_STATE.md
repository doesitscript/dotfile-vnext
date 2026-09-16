# Ansible best-practice refactor — current state

Status date: 2026-09-15  
Repository release: `10.5.0-beta` (`v10.5.0-beta`)  
Repository commit: `2bd1e3e3`

## Current implementation

The model SSOT is `inventory/group_vars/all/ai_cli_apps.yml`. Its
`ai_cli_client_model_contracts` value defines which model roles each client may
consume. Continue accepts chat, edit, apply, autocomplete, and embed. Cline,
OpenCode, and Kilo accept chat, edit, and apply. Their renderers assert that
the configured default model remains in the enabled filtered catalog.

The FIM-only `qwen2.5-coder-1.5b-base-q8_0` and embedding-only
`nomic-embed-text` remain commissioned for their correct roles, but are not
exposed to the agent-client catalogs.

## Current evidence

Completed scoped convergence on `mac-dev`:

```text
Cline:    ok=23 changed=2 failed=0
OpenCode: ok=16 changed=0 failed=0
Kilo:     ok=62 changed=1 failed=0
Continue: ok=16 changed=0 failed=0
```

Ansible syntax checks and `git diff --check` passed. OpenCode reported
version `1.18.26`. Continue reported 11 model rows with autocomplete enabled.
The agent catalogs were inspected and contained neither the FIM nor embedding
lane.


## Evidence boundaries and remaining work

These receipts prove source translation, convergence, rendered configuration,
and catalog safety. They do not claim a full interactive OpenCode or Kilo
behavioral session. A tools-only gate remains a deferred policy decision,
because enforcing it would remove non-tool chat/edit lanes. Aider and Codex
remain profile/single-model surfaces rather than SSOT-backed multi-model
catalogs.

## Document map

- [Plan 06 validation history](plan-06_validating_final_step.md)
- [Plan 13 Cline review](plan-13_cline_client_compatibility_review_reviewed.md)
- [Plan 14 client evaluation receipt](plan-14_clien_and_other_cli_evaluation_reviewed.md)
- [Plan 15 historical evaluation](plan-15_clien_and_other_cli_evaluation_executed_reviewed.md)
- [Plan 15b review input](plan-15b_re-reviewed.md)
- [Plan 15b execution receipt](plan-15b_re-reviewed_executed.md)

## Documentation Provenance

- Origin: completed Plan 15b review and current repository release state.
- Root source of truth: `inventory/group_vars/all/ai_cli_apps.yml` and the
  committed repository at `v10.5.0-beta`.
- Direct inputs: Plans 06, 13, 14, 15, and 15b plus scoped Ansible receipts.
- Outputs: this current-state index for the plan folder.
- Skills used: `documentation-provenance-chain`,
  `plan-packet-evidence-auditor`.
