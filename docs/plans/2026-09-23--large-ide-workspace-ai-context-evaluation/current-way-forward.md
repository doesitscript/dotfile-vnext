# Current way forward: layered AI-facing workspace boundary

Status: active direction after live Context7 research on 2026-09-23.

This file supersedes the pre-Context7 strategy documents archived under
`archive/2026-09-23--superseded-pre-context7-strategy/`. `plan.md` remains the
goals record. Any implementation change must reference this plan folder in its
commit/change note and must update the implementation tracking table below.

## Decision

Treat the repository as a large execution workspace with a smaller AI-facing
source surface. Use layered controls:

1. Git and repository layout establish the shared baseline.
2. Cursor and VS Code settings reduce client indexing, search, and watcher cost.
3. `AGENTS.md`/`.aiignore` explain semantics such as explicit log access.
4. A curated source-only workspace or sandbox is the only cross-client hard
   boundary when shell/MCP access must be impossible.

No blanket exclusion of `playbooks/` or `docs/` is part of this direction.

## Research-backed boundary model

Context7 resolved and queried `/websites/cursor`, `/microsoft/vscode-docs`, and
`/openai/codex`. The resulting source-backed claims are stored in the HRL pack
at:

`/Users/joshc/develop/homelab-reference-library/generated/context7/cursor/ai-workspace-context-boundaries/`

The evaluator must distinguish:

| Evidence stage | Meaning |
|---|---|
| Discovered | A path/name appeared in metadata, listing, or search output |
| Opened/read | File contents were actually requested |
| Tool-output supplied | Content was returned to the model by a tool |
| Model-context confirmed | Client telemetry or a context receipt proves inclusion |
| Response-used | The response materially relied on the content |

Path discovery alone must not be reported as full context consumption.

## Implementation surfaces to inspect and change

| Surface | Desired treatment | Tracking reference |
|---|---|---|
| `.gitignore` | Ignore runtime, cache, generated, archive, binary, and evidence descendants where they are not source; preserve explicit source | This plan, Phase 1 |
| `.cursorignore` | Keep targeted Cursor exclusions for logs, artifacts, generated output, and runtime descendants; do not ignore all `playbooks/` or `docs/` | This plan, Phase 1 |
| `.aiignore` / `AGENTS.md` | State that logs/evidence are opt-in and explicit paths may be inspected; advisory, not access control | This plan, Phase 1 |
| `.vscode/settings.json` | Add or reconcile `files.exclude`, `search.exclude`, and `files.watcherExclude` by category | This plan, Phase 2 |
| Cursor renderer/GPU helper | Measure idle/edit/search/agent states, including active Composer wakelocks that disable background throttling | This plan, Phase 3 |
| Extension host/MCP processes | Attribute CPU and memory by extension/server and test with optional extensions disabled | This plan, Phase 3 |
| `playbooks/` | Attribute the 130 MB before relocating or excluding anything | This plan, Phase 4 |
| `docs/` | Attribute the 25 MB; retain canonical text/source diagrams and isolate generated bulk | This plan, Phase 4 |
| `.venv/` | Preserve `bin/codex-env` execution; exclude from Git/search/watch/context and document rebuild/cache boundaries | This plan, Phase 5 |
| `logs/` | Deprecate repository runtime logs, preserve transition marker/keep-file if needed, and use configured external log roots | Existing log-path plan and this plan |

## Phased way forward

### Phase 1 — repository baseline and evaluator evidence

- Inventory current `.gitignore`, `.cursorignore`, `.aiignore`, and IDE settings.
- Ensure generated/cache/evidence descendants are classified consistently.
- Update the evaluator to report the five evidence stages above.
- Do not classify ordinary readable `playbooks/` or `docs/` as context pollution
  merely because their aggregate directories are large.

### Phase 2 — client performance alignment

- Reconcile Cursor exclusions with the targeted repository categories.
- Add VS Code `files.exclude`, `search.exclude`, and `files.watcherExclude`
  entries only for generated/runtime-heavy categories.
- Keep source playbooks and useful documentation manually discoverable.

### Phase 3 — runtime pressure attribution

- Measure Cursor renderer, GPU helper, extension hosts, MCP servers, language
  servers, open windows, and Composer loops.
- Explain whether “disabled background throttling” is active-only behavior or
  an idle leak.
- Test optional extension disablement as a reversible comparison.

### Phase 4 — `playbooks/` and `docs/` attribution

- Produce file-type, largest-file, tracked/untracked, generated/binary, and
  duplicate-content receipts.
- Relocate or ignore only content proven to be generated/runtime bulk.
- Preserve canonical source and desired diagrams.

### Phase 5 — `.venv/` runtime boundary

- Identify required packages and wrapper dependencies.
- Remove avoidable caches or downloaded artifacts only after confirming the
  rebuild path and tool behavior.
- Keep the environment operationally available but outside normal AI search,
  watcher, and context surfaces.

### Phase 6 — controlled behavioral comparison

- Run the same representative home-lab task in the full workspace and a
  curated source-focused workspace.
- Capture paths opened, tool-output sizes, context receipts where available,
  CPU/memory samples, time to useful answer, tool-call correctness, and failure
  rate.
- Classify workspace hygiene as confirmed cause, contributing cause, or
  unsupported hypothesis; separately classify model/gateway/tool faults.

## Apply / verify / undo

| Contract | Current direction |
|---|---|
| Apply | Implement one phase at a time, beginning with read-only inventory and evaluator evidence |
| Verify | Run the phase-specific probes plus the controlled comparison; preserve receipts under this plan folder |
| Undo | Revert only the phase-owned settings/layout changes; leave source and external log conventions intact unless separately approved |
| Change class | Mostly idempotent configuration and documentation; any relocation/untracking is a separately reviewed migration |

## Change tracking rule

Every future change to `.gitignore`, `.cursorignore`, `.aiignore`,
`.vscode/settings.json`, evaluator skill logic, workspace layout, or runtime
boundary must include a comment or receipt pointing to:

`docs/plans/2026-09-23--large-ide-workspace-ai-context-evaluation/`

### Tracking table

| Date | Surface | Change | Evidence/receipt | Status |
|---|---|---|---|---|
| 2026-09-23 | Codex config | Enabled Context7 in user and project config for research | Live Context7 resolve/query handshake | applied for research |
| 2026-09-23 | HRL | Added Context7-backed layered-boundary research pack | HRL pack and index rebuild; unrelated legacy metadata failures remain | applied with known legacy warnings |
| 2026-09-23 | Plan packet | Archived superseded pre-Context7 strategy; retained goals; made this file active | `archive/` and this file | applied |
| 2026-09-23 | `.cursorignore` | Confirmed targeted logs, artifacts, cache, generated, rendered, runtime, evidence, coordination, transcript, archive, and binary exclusions; preserved `playbooks/` and `docs/` roots | `.cursorignore` plan comment, path probes, and visible-source checks | applied |
| 2026-09-23 | `.aiignore` | Added advisory opt-in semantics for runtime/evidence categories | `.aiignore` plan comment; explicit access remains allowed | applied |
| 2026-09-23 | `.vscode/settings.json` | Added watcher, Explorer, and search exclusions for runtime/evidence categories | JSONC settings review and settings diff | applied |
| 2026-09-23 | `/Users/joshc/develop/dotfile-vnext.code-workspace` | Added the shared multi-root watcher, Explorer, search, and ignore-file settings; workspace-level settings are the active umbrella for all four folders | Workspace JSONC review; Cursor native search A/B rerun pending after reload | applied; reload required |
| 2026-09-23 | Controlled test fixture | Staged one visible `docs/` sentinel and one `.cursorignore`-excluded `artifacts/` sentinel; temporary Git ignore protects the excluded fixture | `git check-ignore` passed for excluded sentinel; native-client search test pending | staged for test |
| 2026-09-23 | Multi-root workspace | Confirmed `/Users/joshc/develop/dotfile-vnext.code-workspace` is an active settings surface with matching watcher/search exclusions and ignore-file settings | Workspace file inspection; see `fixtures/initial-test-receipt-2026-09-23.md` | inspected |
| 2026-09-23 | Boundary test receipt | Preserved Codex `test-unsupported` result and user-reported Cursor results; native search surface remains unidentified for the Cursor result | `fixtures/initial-test-receipt-2026-09-23.md` | recorded; repeat required |
| pending | `.gitignore` | Reconcile any remaining generated/runtime categories after tracked-file inventory | receipt to be added here | pending |
| pending | evaluator skill | Verify five-stage context evidence model | evaluator receipt | pending |
| pending | runtime | Measure renderer/GPU helper/extension/MCP pressure | performance receipt | pending |

## Sources

- Cursor: https://cursor.com/docs/reference/ignore-file
- Cursor safety boundary: https://cursor.com/docs/enterprise/llm-safety-and-controls
- VS Code agent usage: https://github.com/microsoft/vscode-docs/blob/main/docs/agents/guides/optimize-usage.md
- Codex file search: https://github.com/openai/codex/blob/main/codex-rs/file-search/src/lib.rs
- OpenAI sandbox guidance: https://developers.openai.com/api/docs/guides/agents/sandboxes
