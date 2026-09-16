# Cline client compatibility review

Date: 2026-09-16

## Findings and fixes

The Cline catalog was built from every enabled commissioned model. That exposed
the FIM-only `qwen2.5-coder-1.5b-base-q8_0` lane to Cline’s planning/agent model
selector. Cline then sent tools to that lane and LiteLLM correctly rejected the
request because the model does not support tools.

The Cline renderer now filters the shared SSOT to `chat`, `edit`, and `apply`
lanes. FIM and embedding lanes remain available to clients that support those
roles, such as Continue, but are not exposed as Cline agent models. The Cline
role also asserts that its configured default model exists in the filtered
catalog.

## Applied surfaces

- `roles/cline_ide/tasks/mac.yml`: role-aware SSOT filtering and default-model
  membership assertion.
- `roles/cline_ide/templates/models.json.j2`: existing enabled-model render
  path now receives only Cline-compatible lanes.
- Live `mac-dev` Cline state: `~/.cline/data/settings/models.json` contains
  eight enabled chat/edit/apply models and excludes the FIM and embedding IDs.

## Live Cline CLI evidence

Explicit lab-provider probes used:

```text
cline --json --auto-approve false -P openai-compatible -m <model> ...
```

Results:

```text
qwen3-coder-30b-a3b  -> OK, completed
qwen2.5-coder-7b     -> OK, completed
qwen2.5-coder-14b    -> OK, completed
```

The previously problematic `qwen2.5-coder-1.5b-base-q8_0` is no longer in the
Cline model catalog, so Cline cannot select it as an agent model.

## Validation

- Cline convergence on `mac-dev`: `ok=23 changed=3 failed=0`.
- Cline catalog inspection: default `qwen3-coder-30b-a3b`; FIM/embed IDs absent.
- Targeted Cline role lint: 0 failures, 0 warnings.
- Three post-fix Cline lab probes completed successfully.
- Existing Cline cloud providers remain preserved; the lab provider is rendered
  as `openai-compatible`. Cline may persist its own normalized provider state
  after use, so explicit provider selection remains the authoritative runtime
  check.

## Documentation Provenance

- Source findings: user-provided Cline screenshots and live Cline CLI output.
- Implementation source: shared model SSOT, Cline role task, and Cline model
  catalog template.
- Runtime evidence: `mac-dev` Cline convergence, catalog inspection, and three
  post-fix CLI probes on 2026-09-16.
