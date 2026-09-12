# Plan launch directory

## Recommended: one parent chat — paired-plan-orchestrator-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/orchestration/skills/paired-plan-orchestrator-beta/SKILL.md
project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
Copy multi-agent-design/runtime/implementation-config.example.json into a fresh oneoffs/<run-id>/config.json and keep its wired paths: refined_technical_handoff_path, implementation_work_queue_path, expert_recommendation_path, decision_authority_profile_path, operator_resolution_path, orchestration_profile: light, allow_full_tip_resume: false. Do not leave expert/decision-authority null — that is what causes operator questions. Under lab_recreatable_autonomy, auto-adopt Expert Best/Preference; do not ask which of S1–S6 or which researched option to pick. If Implementer hits a named technical fork that is not already settled, require a coordination/requests/*.md file and set consultation_request_path so the On-site Expert (then Researcher) is deployed for that pass — Expert reviews the settled research and recommendations and returns Best; do not ask me to decide. Before scheduling, require both roles to read the refined technical handoff and the latest governed counterpart artifact. Resume causally from that artifact; do not reopen settled research/design work. Run the Implementer/Evaluator pair through multiagents from this parent chat with orchestration_profile: light. Use grouped source-first changes, targeted validation, and design/idempotence review; do not select Full Orchestration unless I explicitly ask for live proof or Apply. Do not materialize plan_dir/execution-records/ unless I explicitly ask. Immediately after the returned session is created and before pass 1, put the exact colorized watch-implementation-output.sh command (with its real session ID and run directory) at the top of your response; it must be the read-only curl-backed monitor, not raw curl JSON. Manage turn handoffs and correction passes, report progress and the dashboard URL here, and handle owned cleanup. Repository implementation and relevant read-only discovery are authorized; preserve specific Apply permissions and verified-target gates. Stop only for genuine missing Apply/target-identity facts or an evidenced final verdict — not for already-researched design choices. I do not want to manage separate worker chats or need a third Observer.
```

## Manual fallback — separate chats

## Implementer — storage-plan-implementer-light-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/implementer/skills/storage-plan-implementer-light-beta/SKILL.md
project_root: /Users/joshc/develop/dotfile-vnext
plan_dir: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign
mode: manual
Run one Implementer pass. I authorize repository implementation and relevant read-only discovery. Progress the storage plan into Ansible changes and receipts; honor existing specific Apply authority without guessing missing targets or permissions. Show the Evaluator launch prompt early, leave a review-ready handoff, and stop.
```

## Evaluator — storage-plan-evaluator-light-beta

```text
Read and use /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md
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
