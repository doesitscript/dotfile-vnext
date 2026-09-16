# Plan 21 — vNext model-lane pytest: scale-up requirements

**Status:** requirements (not yet implemented)  
**Harness owner (new):** sibling Python project
`/Users/joshc/develop/homelab-model-lane-pytest`  
**Skill surface (thin SHIM):** project skill(s) named with required
`-draft` suffix — primary target
`homelab-litellm-model-lane-pytest-draft`  
**Baseline to match or exceed:** global `homelab-litellm-model-lane-pytest`  
**Current thin pass (transitional):** `TDD/test_model_lanes_vnext.py` + Plan 20
draft skill (skill-local / plan-local tests — migrate into the package)

---

## 0. Architecture decision — package owns harness; skills stay thin SHIMs

**Hard rule:** the skill stays a **thin operator/agent surface (SHIM)**; the
Python package owns the harness.

Plan 21 implementation happens **in** `homelab-model-lane-pytest`, not by
growing a second pytest framework under `.cursor/skills/.../lib/` or under
this plan’s `TDD/` folder. Skills **consume** the package (editable path,
wheel, or pinned dependency). Do **not** copy-paste harness `lib/` into every
skill.

### Why this shape

The global skill already grew past “a few scripts in a skill folder”: YAML
manifests, capability gating, receipts, tool harness, runners, unit tests.
Plan 21 wants more (profiles, SSOT sync, targeting). That is **package
territory**, not skill-pack territory.

Skills are good at *when/how to run* and *what evidence to show*. They are
awkward as the long-term home of a growing pytest framework.

### Work split (divvy)

| Layer | Owns | Does **not** own |
| --- | --- | --- |
| **Python project** `homelab-model-lane-pytest` | Client, manifest schema, capabilities, receipts, tool harness, markers/profiles, unit + live tests, normal packaging/typing/CI/versioning | Vault secrets; Ansible inventory SSOT; agent discovery prose |
| **Skill(s)** — **thin SHIM**, name ends in `-draft` until promoted | Discovery (`SKILL.md`), default `human` evidence rules, “do not overclaim,” vault / `bin/*-env` (or documented) launch recipes, links to profiles and package commands | Harness implementation; duplicate journey/receipt/tool code |
| **dotfile-vnext** | Eval manifests / commissioned subset intent, vault wrapper scripts, plan receipts pasted into this plan folder | A second copy of the harness |

Install/consume via editable path, wheel, or pinned dependency — **not** by
vendoring package sources into the skill tree.

### Skill naming — required `-draft` suffix

Any **new** skill created or refreshed for this Plan 21 path **MUST** use the
`-draft` suffix in its skill `name` and folder until an explicit promote
decision removes it.

| Required now | Example |
| --- | --- |
| Suffix | `…-draft` |
| Primary shim | `homelab-litellm-model-lane-pytest-draft` |
| If more shims | e.g. `homelab-…-profile-runner-draft` — still `-draft` |

Do not create a parallel non-`-draft` project skill for this harness while
the package and shim are still under evaluation. Promoting draft → stable
(global or project) is a **separate** decision (see §10).

### What you gain

- Normal Python packaging, typing, CI, versioning in one place
- One harness, many entrypoints (draft skill, later global skill, ATDD
  coordinator)
- Faster iteration without skill-bridge / catalog noise on every harness change
- Clearer TDD: red/green lives in the project; skills do not drift

### What to watch

- Do not strand vault / `codex-env` knowledge only in the package — keep
  launchers in the skill (or a tiny wrapper the skill documents)
- Do not put `ai_cli_commissioned_models` inside the package — keep project
  SSOT in inventory; package accepts manifests/filters
- Version the package; skills pin a floor version so draft and (later) global
  shims do not silently diverge
- Avoid three homes (global skill `lib/` + draft skill `lib/` + new project).
  Migrate once; delete duplicates

### Transitional state

Plan 20’s `TDD/test_model_lanes_vnext.py` and the current draft skill’s
skill-local run path are **transitional**. Treat them as fallback until the
package implements Plan 21 slices and the `-draft` shim points at
`homelab-model-lane-pytest` commands (`just test`, package CLI, profiled
pytest). Do not expand Plan 20 skill-local harness as the long-term home.

Authority already stated on the package side:

> Skills consume this package; test logic does **not** live skill-local.
> (`homelab-model-lane-pytest` README)

---

## 1. Goal

Raise the vNext suite from “six-model HTTP smoke” to the **same product
level** as the global skill — user-journey scenarios, capability-aware matrix,
human expected-vs-actual receipts — while making it **scalable** for many models
with **different capabilities**, and **fast** via targeted selection.

Implementation home: **`homelab-model-lane-pytest`**.  
Agent/operator home: **`-draft` thin SHIM skill(s)** that document how to run
the package and how to report evidence.

This document is the contract for the next draft iteration. Do not claim the
draft skill or package is at global parity until these requirements are
implemented and proven with live receipts.

---

## 2. Current gap (must close)

| Area | Global skill (target level) | Plan 20 vNext draft (today) | Plan 21 target home |
| --- | --- | --- | --- |
| Scenario style | User journeys with `title` / `user_story` | Single “Reply exactly with OK” / FIM insert | Package |
| Receipts | `JOURNEY` / `WHY` / `USER` / `EXPECTED` / `ACTUAL` / `[PASS\|FAIL]` on every run | Thin `MODEL` / `CHECK` / `EXPECTED` / `ACTUAL` / `RESULT` | Package |
| Output modes | Default `human`; optional `machine`/`json`/`ci` | Human-ish print only | Package |
| Capability gating | Lane `capabilities` + scenario `requires_capabilities`; omit inapplicable | Hard-coded `check: chat\|fim` per row | Package |
| Tools | invoke → execute → followup harness | Not covered | Package |
| Embed | Can be a first-class capability lane | Separate ad-hoc test | Package |
| Manifest | YAML lanes + reusable YAML anchors | Python `EVALUATION_LANES` tuple | Package (+ optional eval subset files in dotfile-vnext) |
| Targeting | Markers, `-k`, `-m`, parallel groups | Full six-model parametrization every run | Package |
| SSOT link | Manual manifest | Manual list; not tied to `ai_cli_commissioned_models` labels | Inventory intent → package filters; invariant checks in package |
| Unit tests | Capability gating + human evidence contract without live gateway | Mostly live-only | Package |
| Skill surface | Full harness in skill tree | Plan-local pytest + draft skill docs | **Thin SHIM only** (`-draft`) |

**Non-goal for this iteration:** replacing the global skill overnight. The
draft SHIM stays project-owned; selected patterns may later promote upstream
into the global skill as another thin consumer of the **same** package.

---

## 3. Product requirements (parity with baseline)

### 3.1 User-eccentric journeys (required)

Every live behavioral check must be expressible as a recognizable end-user turn:

- **Smoke:** ping → exact `pong` (communication works).
- **Chat:** explain a tiny function / short coding reply (Continue-class chat).
- **Tools:** ask to read a real file; prove tool request, harness execution, and
  (when supported) follow-up that cites file content.
- **FIM / autocomplete:** partial function body; insert sensible middle text.
- **Embed:** non-empty vector for an owner embed model (when capability present).

Each scenario MUST declare:

- `id`, `group`, `type`
- `title` (shown as `JOURNEY:`)
- `user_story` (shown as `WHY:`)
- `user` prompt
- expectation fields (`expect_exact` / `expect_substrings` / `expect_any_substrings`)
- optional `requires_capabilities: [...]`

Do not add “API returned 200” as the only story. HTTP 200 is necessary but not
sufficient for journey parity.

### 3.2 Human evidence contract (required)

Default output mode is **human**.

- Print a full receipt for **every** executed pass and failure.
- Agents must paste receipt blocks into user-facing reports; pytest counts alone
  are not validation evidence.
- Optional `LITELLM_PROBE_OUTPUT=machine|json|ci` for CI — never the default for
  interactive operator runs.
- Group banners (smoke / llm_chat / llm_tools / llm_fim / embed / infrastructure)
  before related tests, matching the global skill’s functional-group model.

The `-draft` SHIM skill must restate this contract for agents (short); the
package implements it.

### 3.3 Measurement boundary (required)

Passing a probe proves only the named contract (substring/exact/API shape).
Prohibited overclaims:

- IDE round-trip fitness
- grounded repo editing honesty
- “agent is production-ready”
- client executed a tool when only text/JSON was returned

Keep this language in the `-draft` skill `SKILL.md` (SHIM) and in package docs.

### 3.4 Optional human visibility enhancement (non-blocking)

Terminal ANSI color (e.g. red FAIL / green PASS) is **not** in the global
baseline today. If added in vNext:

- must be opt-in or TTY-aware (`NO_COLOR` respected)
- must not break machine/json output
- must not be required for pass/fail correctness

---

## 4. Scalability requirements (more models, different capabilities)

### 4.1 Capability vocabulary (required)

Canonical capability tokens for the matrix (extend only with a written
reason):

| Token | Means | Typical scenarios |
| --- | --- | --- |
| `chat` | Chat completions | smoke, explain-code |
| `tools` | Tool-call API (or declared JSON-in-content adapter) | read-hosts invoke/execute/followup |
| `fim` | Fill-in-middle / autocomplete completions | autocomplete-add-fim |
| `embed` | Embeddings endpoint | embed smoke |
| `edit` / `apply` | Optional role tags for client-oriented suites later | deferred unless journey defined |

A lane that lacks a capability MUST NOT run scenarios that require it. Omission
from the matrix is preferred over skip noise when the lane never advertised the
capability.

### 4.2 Manifest as source of truth (required)

Replace the hard-coded six-model tuple with a **YAML lane manifest** owned by
the **Python package** (e.g. under package `manifests/` or `references/`),
shaped like the global `homelab-default-lanes.yml`:

- `lanes[]` with `id`, `label`, `capabilities`, `usage[]`
- YAML anchors for reusable journeys (`x-smoke-ping-pong`, `x-fim-add-function`, …)
- Per-family FIM prompt overrides when token formats differ

Adding a model = add/edit a lane row + capabilities + which anchors apply.
Adding a journey once = reuse across all capable lanes.

Optional **eval-subset** overlays may live in dotfile-vnext (commissioned
subset for this lab) and be passed into the package — still no harness fork.

### 4.3 Align with project SSOT (required direction)

Project commissioned models live in
`inventory/group_vars/all/ai_cli_apps.yml` → `ai_cli_commissioned_models`
(`labels`, `context`, `max_output`, `enabled`).

vNext MUST:

1. Treat inventory labels as the **intent** for which capabilities a
   commissioned model should advertise in the test manifest (at least:
   `chat`/`edit`/`apply` → chat journeys; `autocomplete` → fim; `embed` → embed;
   `tools` → tools journeys).
2. Allow a deliberate **evaluation subset** (not every commissioned model every
   run) via an eval profile or CLI filter.
3. Fail or warn (policy choice, document it) when a commissioned `enabled: true`
   model with `tools` is missing from the tools-capable eval set if the operator
   requested “full commissioned coverage.”

Do **not** require loading Ansible at pytest import time. Prefer a generated or
hand-synced manifest with a small invariant test that the eval set ⊆ commissioned
ids (or documents intentional extras). Inventory stays in dotfile-vnext; the
package consumes exported/synced data.

### 4.4 Heterogeneous models (required)

The matrix must support coexistence of:

- chat-only small models
- chat+tools agent models
- FIM-only / FIM-primary base models (no tools)
- embed-only owners
- large-context chat models with different `max_tokens` / context guards
- disabled / pending models (`enabled: false`) excluded from live default runs

Context-budget and response-shape guards from Plan 20 may remain as
**infrastructure** or **invariant** checks, separate from user-journey grades.

---

## 5. Speed and targeting requirements

Full-matrix live runs against every model and every journey will not stay fast.
vNext MUST optimize for **targeted** operator workflows.

### 5.1 Selection surfaces (required)

Support at least:

| Mechanism | Example intent |
| --- | --- |
| Pytest markers | `-m smoke`, `-m llm_tools`, `-m "llm_chat or llm_fim"` |
| Keyword / id filter | `-k "30b or ping-pong"` |
| Env / CLI lane filter | `LITELLM_LANE_FILTER=qwen3-coder-30b-a3b,gpt-oss-20b` |
| Eval profile | `smoke`, `pr`, `nightly`, `capability-tools`, `commissioned-six` |
| Capability filter | only lanes with `tools`, or only scenarios requiring `fim` |

Default interactive profile for day-to-day work: **smoke + one chat journey**
on the eval subset, not tools+FIM+embed for everything.

The `-draft` SHIM documents the preferred one-liners (`just …` / package CLI /
pytest profile); the package implements the filters.

### 5.2 Parallelism and residency (required)

- Preserve sequential-friendly defaults so a single-GPU host need not hold all
  weights at once.
- Optional `pytest-xdist` with `xdist_group` per functional group (mirror global
  skill) — opt-in, not default on memory-constrained hosts.
- Document that live latency is dominated by model load/inference, not Python;
  targeting is the primary speed lever.

### 5.3 Fast feedback without the gateway (required)

Keep a non-live unit layer **in the package** that proves:

- capability gating / scenario omission
- human receipt formatting (pass and fail both print)
- manifest schema load
- SSOT id invariants

These must run in seconds with no `LITELLM_API_KEY` (`just test` unit subset).

### 5.4 Skip vs omit policy (required)

| Case | Behavior |
| --- | --- |
| Lane lacks capability | **Omit** scenario from matrix |
| Key unset | **Skip** live tests with clear reason |
| Lane `enabled: false` / pending | **Omit** from default live profile |
| Network/gateway down | Fail with actionable error (do not silent-pass) |

---

## 6. Python / pytest TDD practices (required)

Use the package’s uv/just/Ruff/pytest stack (`homelab-model-lane-pytest`). Do
not invent a second harness shape inside the skill.

### 6.1 Structure (package)

- `src/homelab_model_lane_pytest/` — public API + helpers: client, manifest
  load, receipts, capabilities, tool harness, output mode
- `tests/` — unit contracts + live parametrized suites
- package-owned `manifests/` or `references/` for YAML lanes
- `just` recipes for setup / unit / live / lint
- Thin CLI entry (`homelab-model-lane-pytest`) for operator profiles

### 6.2 Structure (skill SHIM only)

`-draft` skill tree should stay thin:

- `SKILL.md` — when to use, evidence rules, measurement boundary, run recipes
  that invoke the package
- optional tiny `scripts/` that only wrap env/vault + call into the package
- **no** growing `lib/` of journey/receipt/tool logic

Vault key injection stays outside the test body — keep a
`run_*_with_vault.sh` (or equivalent) pattern **documented by the SHIM**,
implemented as a thin wrapper.

### 6.3 TDD loop for new coverage

When adding a model or journey:

1. **Write the scenario first** (EXPECTED + `user_story`) in YAML — red/fail or
   omitted until wired.
2. Add/adjust lane `capabilities`.
3. Run **unit** gating tests in the package (no gateway).
4. Run **targeted** live profile for that lane/journey only.
5. Tighten expectations from real receipts; do **not** weaken
   `expect_substrings` / `expect_exact` just to force green.
6. Paste human receipts into the plan/execution receipt (dotfile-vnext plan
   folder).

### 6.4 Code quality bars

- Type hints on public helpers; frozen dataclasses for lane/scenario specs
- Parametrize with stable `ids=` (lane + group + scenario)
- No secrets in source, fixtures, or plan markdown
- Prefer pure functions for grading; I/O at the edges
- One assertion story per receipt step (tools: separate receipts for invoke /
  execute / followup)
- Idempotent tests: no shared mutable gateway state assumptions
- Package lint/test via `just lint` / `just test`

### 6.5 Reuse before rewrite

Prefer importing patterns from
`global-skills/.../homelab-litellm-model-lane-pytest` **into the package**
(receipt format, capability helpers, tool harness) over forking divergent
semantics inside a skill. If the package must diverge from the global skill’s
old in-tree lib, document why in package docs + the `-draft` SHIM.

Migrate once; retire duplicate Plan 20 / skill-local copies.

---

## 7. Evidence and agent reporting (required)

Mirror the global skill agent rules; enforce via the `-draft` SHIM:

1. Default human mode; show every PASS and FAIL receipt.
2. Distinguishing `skipped` from `passed` is mandatory in plan receipts.
3. Prohibited: “N passed” without blocks; failures-only when human was default;
   switching to machine mode without an explicit ask.

---

## 8. Suggested implementation slices (ordered)

Use these as checklist slices for the next execute pass — not optional flavor.

1. **Package bootstrap → harness spine** — grow `homelab-model-lane-pytest`
   from scaffold to client/manifest/receipts skeleton; wire `just test` unit
   path.
2. **Manifest + capabilities** — YAML lanes for current six (+ embed owner);
   gate scenarios; unit tests for omit/skip (**in package**).
3. **Human receipts** — JOURNEY/WHY/USER/EXPECTED/ACTUAL parity with global
   skill; output mode switch (**in package**).
4. **Journey library** — smoke, chat explain, FIM, embed; wire only where
   capabilities allow (**in package**).
5. **Tools path** — read-hosts invoke/execute/followup for `tools`-capable eval
   lanes only (**in package**).
6. **Targeting** — markers, lane filter env, eval profiles (`smoke`, `pr`,
   `nightly`) (**in package**); SHIM documents preferred commands.
7. **SSOT invariant** — eval ids ⊆ / aligned with `ai_cli_commissioned_models`
   labels (generated check or documented sync script; inventory stays in
   dotfile-vnext).
8. **Thin SHIM skill update** — refresh
   `homelab-litellm-model-lane-pytest-draft` `SKILL.md` to point at the package;
   keep **`-draft` suffix** until promoted; remove/stop expanding skill-local
   harness.
9. **Retire transitional Plan 20 path** — once package parity for the eval
   subset is proven, mark `TDD/test_model_lanes_vnext.py` as superseded (or
   delete in a later cleanup slice).
10. **Optional** — TTY-aware colored FAIL/PASS; xdist opt-in.

---

## 9. Done when

The draft iteration is complete only when all are true:

- [ ] Harness logic lives in `homelab-model-lane-pytest`; skills are thin SHIMs
      only.
- [ ] Every new/updated Plan 21 skill name ends with `-draft` until promote.
- [ ] New models with mixed capabilities can be added primarily via YAML, not
      new Python branches per model.
- [ ] Inapplicable journeys are omitted by capability, not asserted falsely.
- [ ] Operators can run a **targeted** subset in one package command (documented
      by the SHIM) and get human receipts for every executed case.
- [ ] Smoke + at least one chat journey + FIM (where capable) + embed owner
      match the **user-journey quality** of the global skill (not merely HTTP
      200 smokes).
- [ ] Tools journeys exist for at least one tools-capable eval model, with
      per-step receipts.
- [ ] Non-live unit tests cover gating + receipt contract (`just test` in the
      package).
- [ ] Draft SHIM documents run profiles, measurement boundary, vault key rules,
      and package path/version pin.
- [ ] A live targeted run’s receipt blocks are captured in an execution note
      under this plan folder.

---

## 10. Out of scope (explicit)

- Deploying/changing LiteLLM, vLLM, or inventory routes
- Full IDE UI automation (Continue/Cline click-through)
- Replacing `homelab-model-lane-atdd-coordinator` campaign workflow
- Promoting draft SHIM → non-`-draft` / global skill (separate decision)
- Enabling `require_any_labels: [tools]` client catalog policy (Ansible client
  contract; not this pytest suite)
- Re-homing the global skill’s full tree into the package in the same pass
  (allowed later; Plan 21 may import patterns without deleting global skill yet)

---

## 11. Authority and provenance

| Layer | Path |
| --- | --- |
| Package harness (owner) | `/Users/joshc/develop/homelab-model-lane-pytest` |
| Global baseline (behavior) | `global-skills/skills/validation/homelab-litellm-model-lane-pytest/` |
| Project thin SHIM (`-draft`) | `.cursor/skills/homelab-litellm-model-lane-pytest-draft/` |
| Plan 20 first pass (transitional) | `TDD/test_model_lanes_vnext.py`, `TDD/README_vnext.md` |
| Commissioned model SSOT | `inventory/group_vars/all/ai_cli_apps.yml` |
| Client role filters | `ai_cli_client_model_contracts` (related; not owned here) |
| Design decision (conversation) | thin SHIM skill + package-owned harness ([Plan 21 design](8955ed73-ffd2-4bb0-b6bd-64821b08fb34)) |
| This requirements packet | `plan-21_vnext_skill_draft.md` |

**Apply / Verify / Undo / Change class (for when implementation starts):**

- **Apply:** implement slices 1–9 primarily under `homelab-model-lane-pytest`;
  keep `-draft` skill as SHIM docs/wrappers only; keep global skill untouched
  unless promoting shared helpers into the package.
- **Verify:** package unit suite green without key; targeted live profile with
  pasted human receipts; SHIM run recipes match package commands;
  marker/filter demos documented.
- **Undo:** revert package + SHIM changes; Plan 20 thin suite remains fallback
  until explicitly retired.
- **Change class:** idempotent test/harness evolution (non-destructive to
  runtime hosts).

---

## Diagram inventory (requirements-only)

No architecture diagram required for this requirements write-up. When
implementation starts, add:

1. **Ownership / SHIM diagram** — package vs `-draft` skill vs dotfile-vnext
   inventory/vault vs global baseline
2. **Capability Routing diagram** — lane capabilities → scenario groups →
   markers/profiles

under this plan folder.
