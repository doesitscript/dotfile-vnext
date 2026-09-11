# Plan launch directory

## Recommended: one parent chat — paired-plan-orchestrator-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/orchestration/skills/paired-plan-orchestrator-beta/SKILL.md
project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
Run the Implementer/Evaluator pair through multiagents from this parent chat. Manage turn handoffs and correction passes, report progress and the dashboard URL here, and handle owned cleanup. Repository implementation and relevant read-only discovery are authorized; preserve specific Apply permissions and verified-target gates. Stop for genuine unresolved user decisions or an evidenced final verdict. I do not want to manage separate worker chats or need a third Observer.
```

## Manual fallback — separate chats

## Implementer — storage-plan-implementer-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/implementer/skills/storage-plan-implementer-beta/SKILL.md
project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
mode: manual
Run one Implementer pass. I authorize repository implementation and relevant read-only discovery. Progress the storage plan into Ansible changes and receipts; honor existing specific Apply authority without guessing missing targets or permissions. Show the Evaluator launch prompt early, leave a review-ready handoff, and stop.
```

## Evaluator — storage-plan-evaluator-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/evaluator/skills/storage-plan-evaluator-beta/SKILL.md
project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
mode: manual
Run one Evaluator pass. Show the Implementer and optional Observer launch prompts early. Review the latest implementation and evidence against the full campaign, write one feedback/waiting/ready artifact, and stop. No implementation handoff yet means waiting, not approval. Do not implement fixes or mutate hosts.
```

## Observer — multiagent-plan-observer-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/observer/skills/multiagent-plan-observer-beta/SKILL.md
project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
Observe read-only for up to five minutes. Report the dashboard URL/status and brief useful handoff changes. Use runtime slots only with an explicit campaign session mapping. Do not change files, drain inboxes, message agents, start/stop services or approve work.
```

## Re-entry — same role and chat

```text
Continue one pass on the same campaign with the same adapter skill. Read the newest counterpart artifact and current evidence, use a fresh invocation ID, leave your role's handoff, and stop.
```

## Preparation roles — when another preparation pass is needed

- [Coordinator prompt + skill](multi-agent-design/agent-prompts/onsite-expert-coordinator-draft-prompt.md)
- [Researcher prompt + skill](multi-agent-design/agent-prompts/researcher-draft-prompt.md)
