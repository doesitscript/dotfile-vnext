# Launch the storage implementation pair + optional Observer

**Preferred:** use the single-parent prompt at the top of
[launch-directory.md](../../launch-directory.md). It manages the pair through
multiagents and includes progress observation. The separate-chat prompts below
remain a manual fallback; a third Observer is optional.

Concise copy/paste directory: [launch-directory.md](../../launch-directory.md).
At initial activation, Implementer prints the Evaluator launch block; Evaluator
prints the Implementer and optional Observer blocks before substantive work.
The skills load these blocks from that directory; they do not start peers.

These project-owned adapter skills explicitly load the mature global role packs.
No skill installation, global-role rewrite, team creation or dashboard startup
is required. Full file paths work even when the new names are not discoverable
as `$skills`. Read/use the skill file; do not just mention its name.

Start Implementer first. Run Evaluator when an Implementer review-ready artifact
exists (starting it earlier yields one waiting artifact). Use Observer whenever
helpful. All three use the same campaign directory. Ordinary chats need manual
re-entry after a role stops; these prompts do not create an automatic scheduler.

## 1. Implementer — paste in its own agent chat

```text
Read and use this project adapter skill in full:
/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/implementer/skills/storage-plan-implementer-beta/SKILL.md

project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
mode: manual

Act as Implementer. Load the mature paired-agent-plan-implementer pack required
by the adapter. Verify the reviewed upstream intake; use the shared campaign ID
and generate a unique invocation run ID. I authorize repository implementation
and relevant read-only live discovery for this storage campaign. Make practical
progress from S1 into the supported Ansible roles/playbooks, not another generic
planning exercise. Honor existing specific live-Apply authorization; record it
with exact verified targets and rollback. If a destructive target/policy or
Apply permission is missing, ask only that unresolved decision and continue
independent safe work. Do not infer it from this prompt.

Keep all S1–S6 obligations visible, particularly actual new storage/offload.
Update accounting and execution/validation receipts, then leave one concrete
review-ready handoff for the Evaluator and stop this pass. Do not launch peers,
poll, start a dashboard, edit frozen upstream or self-approve. Preserve unrelated
work. We want useful implementation and slightly better work in scope, not a
whole-project best-practice audit.
```

## 2. Evaluator — paste in a second agent chat

```text
Read and use this project adapter skill in full:
/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/evaluator/skills/storage-plan-evaluator-beta/SKILL.md

project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
mode: manual

Act as Evaluator. Load the mature paired-agent-plan-evaluator pack required by
the adapter. Verify upstream intake and campaign identity; generate a unique
invocation run ID. Evaluate the latest Implementer outbox, actual source changes
and receipts against all S1–S6 obligations, with focused independent Ansible
research/verification as needed. Preparation review and adapter tests are not
implementation approval. Report actionable task-scoped findings; avoid unrelated
project cleanup. Do not mutate hosts or fix the Implementer's files.

Write exactly one mature feedback, waiting or ready artifact for the current
evidence and stop. Ready means the whole campaign is verified, including actual
storage/offload and any explicitly approved scope changes—not just discovery or
one successful slice. If there is no outbox yet, leave one waiting artifact.
Do not poll, start services, launch peers or approve from broker status alone.
```

## 3. Observer — paste here or in a third chat

```text
Read and use this read-only project skill in full:
/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/observer/skills/multiagent-plan-observer-beta/SKILL.md

project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign

Observe this campaign for up to five minutes. Give a brief initial snapshot,
then only useful changes, and a short closing observation. Report the dashboard
URL and actual status; observe runtime slots only if this campaign has an
explicitly supplied session mapping. Otherwise observe the durable handoffs
and explain that the separate manual chats are not a broker-managed team.
Do not drain inboxes, send messages, change files, start/stop services, evaluate
the implementation or control either agent. Keep it lightweight and interruptible.
```

For one snapshot instead, replace `Observe ... five minutes` with `Take one
read-only snapshot and stop`. No background watcher remains after either mode.

## Re-entry and optional managed execution

In the same role's chat, after its counterpart's artifact exists:

```text
Continue one pass on the same campaign using the same adapter skill. Read the
newest counterpart artifact and current evidence, generate a fresh invocation
ID, perform your role's next pass, leave its durable handoff, and stop.
```

The parent orchestrator supplies managed session/slot/ownership inputs
and route the same finite passes through the [integration contract](../orchestration/implementation-beta-contract.md).
Use the separate `runtime/run-implementation.ts` runner for that loop; the
preparation controller must not be used as an implementation runner.

Dashboard: http://127.0.0.1:7900 — observe status at invocation; may be shared or
MCP-managed independently of the campaign. These prompts do not claim ownership.
