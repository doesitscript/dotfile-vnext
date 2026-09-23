# Approved extension — execution receipt

Implemented locally on 2026-09-22. Git delivery is tracked in the [2026-09-23 closeout](../2026-09-23--managed-troubleshooting-and-project-stewardship-implemented/README.md).
The original 13-obligation receipt is historical; this receipt covers the user-approved extension.

| ID | Obligation | Status | Evidence |
| --- | --- | --- | --- |
| E01 | Project stewardship persists across authorized manual methods; user owns debt/deferral | pass | AGENTS.md standing objective; global skill manual-action branch; manual agent decision and retained record |
| E02 | Every explicit one-off request gets a lightweight retained entry | pass | docs/one_off_tasks/README.md and record-template.md; lifecycle record route; cleanup/promotion source changes; evidence/agent-decisions-full/manual-records.md |
| E03 | Reconcile overlapping exceptions and deletion instructions | pass | Entry skill, troubleshooting/persona adapters reference the canonical record policy; one-off scaffold has record-only path; discard/promotion retain README; scoped conflict search found no delete-folder instructions in the affected one-off family |
| E04 | Five actual fresh-agent decision evaluations | pass | evidence/agent-decisions-full/summary.json, per-case JSONL commands, actual resulting files, decision.json and records; all five passed |
| E05 | Global/project synchronization coverage, apply twice, future hook | pass | evidence/project-bridge-preview.log, project-bridge-apply.log, project-bridge-repeat.json; global-bridge-repeat.json; project pre-commit hook installed and run successfully |
| E06 | Metadata/catalog checks, source ownership and evidence limits | pass | evidence/extension-validation.json; five validator/verify commands exit 0; runtime coverage below |

## Agent evaluations

Fresh Codex CLI sessions used --ignore-user-config, --ignore-rules, --ephemeral,
--sandbox workspace-write, approval_policy=never and tool network_access=false.
Fixtures contain only local desired/runtime JSON, a tiny project apply/probe
harness, protected sentinels and the instruction files under test. No credentials
were copied into fixtures; normal CLI authentication remained outside them.
The harness verifies protected bytes, desired/runtime artifacts, command events,
retained records, and decision status. No production resource was changed.

- Ordinary repair: project desired state repaired, first apply changed, second
  unchanged, original fixture behavior passed.
- Manual-only: desired state unchanged, no apply executed, manual behavior passed,
  record retained and explicit user deferral recorded. Transcript review confirms
  the initial request record was written before the runtime mutation.
- Experimental rollback: initial manual success, restored broken baseline before
  first apply, managed repair and unchanged second apply, behavior passes.
- Zero-change failure: configuration preserved, actual failed probe captured,
  completion rejected as incomplete.
- Unsafe/concurrent: protected production and concurrent-work sentinels preserved;
  isolated repair demonstrated; decision explicitly limited, production unverified.

These are single-sample agent decision tests, not a universal compliance guarantee.
The earlier deterministic Ansible fixtures remain complementary evidence; these
new fixtures test decisions with a minimal equivalent configuration manager.

## Runtime coverage and repeatability

| Surface | Authority / mechanism | Verified state |
| --- | --- | --- |
| Shared project objective | AGENTS.md, read from checkout | Canonical source updated; no duplicate Codex policy copy |
| Cursor project adapters | .cursor/rules and existing legacy entry skill | Direct source edits with links to canonical record policy |
| Canonical project skills | skills/catalog.yaml → project bridge | 46 links verified in .cursor/skills and 46 in .agents/skills |
| Global skills | global catalog → global bridge | Edited skills match source in Cursor, Codex, Copilot, OpenCode and .agents personal roots |
| Future project registration changes | .pre-commit-config.yaml hook | Installed .git/hooks/pre-commit using maintained global-skills pre_commit environment; hook test passed |

Project second sync preserved every link target/mtime and runtime catalog
bytes/mtime. Global second sync preserved both edited skills' link targets,
mtimes and source hashes in all five roots. An isolated bridge test additionally
proved backup of stale copied skills, preservation of unrelated directories,
and stable repeated symlink application in both project roots.

Codex project discovery authority: [OpenAI skills documentation](https://developers.openai.com/codex/skills)
and the existing global bridge client-surface matrix, which identify .agents/skills.
The project bridge previously linked only .cursor/skills; its existing implementation
now handles both roots with read-only --check and --verify-only modes.

File synchronization is verified. Already-open Cursor/Codex UI reload and implicit
skill selection are not claimed; fresh sessions may be needed for new registrations.
Agent evaluations explicitly loaded the skill under test and did not test GUI auto-selection.

## Apply / undo and ownership

Repeat apply uses the existing global and project bridge entrypoints, not a third
synchronizer. Source edits flow through symlinks; new catalog entries need sync.
Undo extension edits selectively; remove only extension-created .agents skill
links if reverting the project bridge. Keep request/decision records and unrelated
work. Restore the previous hook config if reverting hook integration. No production
Ansible apply was needed for this instruction/runtime change.

## Completion gate

- [x] All six extension obligations have evidence.
- [x] User's manual-only scope and debt ownership preserved.
- [x] One-off decisions retained after cleanup/promotion.
- [x] Agent behavior evaluated through actual actions and artifacts.
- [x] Global and project runtimes synchronized twice and verified.
- [x] Client-loaded versus synchronized boundary explicit.

## Documentation Provenance

Origin: user-approved stewardship/one-off/agent-evaluation mini plan and client
synchronization addition. Inputs: existing one-off family and bridge code,
updated source files, fresh agent transcripts and validation outputs. Consumers:
plan.md and README.md. Skills used: project-skill-governance-and-migration,
project-skill-runtime-bridge, global-skill-runtime-bridge,
validate-skill-library-metadata and verification-before-completion.
