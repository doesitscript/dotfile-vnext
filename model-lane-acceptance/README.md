# Model-lane acceptance (ATDD)

Project-owned **acceptance criteria** for homelab LiteLLM `model@host` lanes and
Codex CLI profiles. The pytest **harness** lives in global-skills; this folder is
the dotfile-vnext source of truth for **what** must pass.

## Agnostic vs project-specific

| Agnostic (global-skills) | Project-specific (this folder) |
| --- | --- |
| `run_model_lane_pytest.py`, receipts, tests | `gateway/manifest.yml` |
| Capability gating mechanics | `gateway/lane-decisions.md` |
| Codex subprocess probe code | `codex/profiles-approved.yml`, `codex/pending/*` |
| Human vs machine output modes | `client-map.yml` — which client uses which lane |

## ATDD workflow

Full developer flow diagram:
[`docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/diagrams/atdd-developer-flow.md`](docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/diagrams/atdd-developer-flow.md)

Coordination plan (acceptance author + stack implementer handoffs):
[`docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/README.md`](docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/README.md)

> **Stack implementer** is a role — agent and client surface vary by campaign (Codex CLI is one example).

1. **You** define the user journey (communication, code explain, tool round trip, FIM).
2. **Acceptance author** writes or updates YAML here with `title`, `user_story`, and EXPECTED fields **before** treating the lane as approved.
3. **Stack implementer** changes runtime, gateway routes, or parsers until probes pass.
4. **Promote** only when live receipts show PASS for every step — move `pending/` → approved manifest.

Default probe output is **human**: print USER / EXPECTED / ACTUAL for every pass
and failure. Do not report only pytest counts.

## Layout

```text
gateway/manifest.yml           → LITELLM_MODEL_LANE_MANIFEST (approved gateway contracts)
gateway/pending/               → criteria not yet green
codex/profiles-approved.yml    → CODEX_CLI_MODEL_PROFILE_MANIFEST (approved CLI contracts)
codex/pending/                 → ATDD specs (e.g. shell tool-loop; may fail by design)
client-map.yml                 → Continue / Kilo / Codex profile → lane mapping
scripts/run-gateway-acceptance.sh
scripts/run-codex-acceptance.sh
```

## Run

From repo root (requires `LITELLM_API_KEY` and reachable `litellm.hom.lab`):

```bash
# All approved gateway journeys
./model-lane-acceptance/scripts/run-gateway-acceptance.sh

# Smoke only
./model-lane-acceptance/scripts/run-gateway-acceptance.sh -m smoke -v -s

# Approved Codex profiles
./model-lane-acceptance/scripts/run-codex-acceptance.sh

# Pending ATDD — tool loop (expect FAIL until Codex executes shell)
./model-lane-acceptance/scripts/run-codex-acceptance.sh pending/tool-loop.yml -v -s
```

Override harness location:

```bash
export GLOBAL_SKILLS_ROOT=/path/to/global-skills
```

## Related docs

- [`client-map.yml`](client-map.yml)
- [`gateway/lane-decisions.md`](gateway/lane-decisions.md)
- Plan: `docs/plans/2026-09-01--homelab-local-ai-clients-codex/`
- HRL: `homelab-reference-library/implementation-guides/pytest/user-journey-receipt-tests.md`
