# dotfile-vnext model-lane acceptance (ATDD) — layout

**Status:** implemented at repo root → [`model-lane-acceptance/`](../../../../model-lane-acceptance/README.md)

The large `evals/suites/coding/python_tdd/...` tree in the original brainstorm was
**inspiration only**. This project uses a simpler split:

| Layer | Where | What it holds |
| --- | --- | --- |
| **Harness (agnostic)** | `global-skills/.../homelab-litellm-model-lane-pytest` | pytest runner, receipts, capability gating, HTTP/Codex probes |
| **Acceptance specs (this repo)** | `model-lane-acceptance/` | YAML manifests, client map, ATDD **approved** vs **pending**, run scripts |

## Developer flow

One-page diagram and role handoffs:
[`draft-multi-agent-vnext-plan-work/diagrams/atdd-developer-flow.md`](draft-multi-agent-vnext-plan-work/diagrams/atdd-developer-flow.md)

ATDD in short: you describe the journey → acceptance author writes EXPECTED YAML →
implementer fixes stack from FAIL receipts → promote when all steps PASS.
Human mode: every PASS/FAIL receipt block is evidence; summaries alone are not enough.

## Workflow (ATDD + implementer pairing) — short form

```text
You          → user journey ("Kilo needs tool round trip")
Cursor       → write/update acceptance YAML (EXPECTED first) in model-lane-acceptance/
Implementer  → implement/deploy until receipts green  (name TBD)
Promote      → pending/ → approved manifest only when all receipts PASS
```

Human mode by default: every PASS and FAIL receipt block is evidence; summaries
alone are not enough.

## Folder layout (implemented)

```text
model-lane-acceptance/
├── README.md
├── client-map.yml              # which client/profile → which model@host lane
├── gateway/
│   ├── manifest.yml            # project SSOT — LITELLM_MODEL_LANE_MANIFEST
│   ├── lane-decisions.md       # calibration notes for this homelab fleet
│   └── pending/                # ATDD criteria written before runtime is ready
│       └── README.md
├── codex/
│   ├── profiles-approved.yml   # contracts that passed live probes
│   ├── profile-map.yml         # codex-homelab profile → lane
│   └── pending/                # e.g. shell tool-loop — expect FAIL until runtime fixed
│       └── tool-loop.yml
├── scripts/
│   ├── run-gateway-acceptance.sh
│   └── run-codex-acceptance.sh
└── results/                    # optional filed reports (gitignored artifacts)
    └── .gitkeep
```

## Run

```bash
# Gateway lanes (human receipts, default)
./model-lane-acceptance/scripts/run-gateway-acceptance.sh

# Codex approved profiles
./model-lane-acceptance/scripts/run-codex-acceptance.sh

# ATDD pending — expect FAIL until implementation catches up
./model-lane-acceptance/scripts/run-codex-acceptance.sh pending/tool-loop.yml
```

## What stays out of this folder

- pytest code, `UsageReceipt` formatter, `litellm_lane_client.py` → global-skills
- Ansible deploy roles, inventory, Codex `templates/*.config.toml` → existing plan paths
- Future agnostic skill: would **read** manifests from paths like this; harness unchanged

## References

- Client/model map: [`implementor_output/role_implementor__client-model-map.md`](implementor_output/role_implementor__client-model-map.md)
- HRL: `homelab-reference-library/implementation-guides/pytest/user-journey-receipt-tests.md`
- Global skill: `global-skills/skills/validation/homelab-litellm-model-lane-pytest`

## Deferred — scale and layout (revisit next session)

**Park this for a follow-up discussion.** The current `model-lane-acceptance/` layout is
intentionally small and stable for today's homelab fleet (one approved gateway manifest,
one Codex approved file, a `pending/` bucket per surface).

We have **not** yet designed for:

- **Multiple evaluation runs** on different days (history, baselines, regression compare)
- **Different use groups** (e.g. Kilo vs Continue vs Codex vs future clients) each with
  their own acceptance slices without duplicating journeys
- **Different model cohorts** evaluated in parallel (candidate lanes, A/B, seasonal retests)

When we come back to this, expect the **folder structure and file layout to change** —
likely something like grouping by `client/` or `suite/` + dated `results/`, or separate
manifest trees per evaluation campaign — while keeping the global-skills harness agnostic.

**Next time:** start here and make the multi-day / multi-group / multi-use layout explicit
before adding more manifests or results under the flat tree above.
