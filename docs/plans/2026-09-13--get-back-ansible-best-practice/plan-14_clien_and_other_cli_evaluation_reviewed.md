# Plan 14 — Client and other CLI evaluation (reviewed)

Date: 2026-09-15

## Outcome

The evaluation finding was implemented as a shared, role-aware client model
contract. `ai_cli_commissioned_models` remains the model SSOT; each client role
selects only the model roles it can safely consume and asserts that its default
model remains selectable.

## Applied changes

- Added `ai_cli_client_model_contracts` to
  `inventory/group_vars/all/ai_cli_apps.yml`.
- Continue selects chat/edit/apply/autocomplete/embed rows.
- Cline, OpenCode, and Kilo select chat/edit/apply rows only, excluding the
  FIM-only and embedding-only lanes from agent model catalogs.
- OpenCode receives per-model context and output limits from the SSOT.
- Kilo receives per-model context, output, input, and tool-call metadata from
  the SSOT. Tool calls are derived from the `tools` label rather than being
  hardcoded per model.
- OpenCode's duplicated task block was removed.

## Convergence evidence

Commands executed from the repository root:

```bash
bin/codex-env ansible-playbook playbooks/deploy_cline_ide.yaml \
  -i inventory/inventory.yaml --limit mac-dev
bin/codex-env ansible-playbook playbooks/deploy_opencode_cli.yaml \
  -i inventory/inventory.yaml --limit mac-dev
bin/codex-env ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml --limit mac-dev --tags kilo_ide
```

Results:

```text
Cline:    ok=23 changed=2 failed=0
OpenCode: ok=16 changed=0 failed=0
Kilo run: ok=62 changed=1 failed=0
```

Role assertions passed for all three agent clients, including default-model
membership. OpenCode reported version `1.18.26`. Rendered mac-dev catalogs
reported 9 model rows before enabled filtering and contained no
`qwen2.5-coder-1.5b-base-q8_0` or `nomic-embed-text` entries in the agent
client catalogs. Cline's rendered catalog retained the expected tool
capability only on the Qwen3 and GPT-OSS tool-labelled rows.

## Remaining boundary

This proves source translation, convergence, rendered catalog shape, and
client configuration safety. It does not claim a full interactive OpenCode or
Kilo user-session behavioral test. Those require invoking each client with a
real user prompt and, for agent behavior, a disposable workspace/tool action.
The generic download registry and route-loop refactors remain outside this
execution because they were not required to resolve the client compatibility
finding.

## Documentation Provenance

- Source findings: `plan-14_clien_and_other_cli_evaluation.md` and the prior
  Cline compatibility review.
- Implementation source: model SSOT, client capability contract, and the
  Continue/Cline/OpenCode/Kilo role renderers.
- Runtime evidence: scoped Ansible convergence and rendered mac-dev catalog
  inspection on 2026-09-15.
