# AGENTS.md

This file defines the durable repo-specific guidance for Codex in this project.

Keep it small. Durable behavior lives here. Deeper rationale lives in `docs/codex_framework/partner_process.md`. The capability map for this framework lives in `docs/codex_framework/README.md`.

## Instruction Bootstrap

For Codex/OpenAI conversations in this repo, treat this file as the highest
repo-level enforcement surface.

Before substantive work, load the repo's Codex-native framework surfaces in
this order:
1. `AGENTS.md`
2. project `.codex/config.toml`
3. `docs/codex_framework/README.md`
4. `docs/codex_framework/partner_process.md`
5. `docs/codex_framework/capability_introduction_checklist.md` when adding roles,
   playbooks, or new naming surfaces
6. active `framework-*` files under `.cursor/rules/`, plus any explicitly
   referenced supporting rule files
7. `docs/codex_framework/plan-governance-dependencies.md` and `docs/plans/README.md`
   Required Diagram Checklist when writing or promoting under `docs/plans/`

For this repo, framework docs and the referenced `framework-*` rule family are
not optional background reading in Codex/OpenAI conversations. This file
bootstraps them.

Treat `.cursorrules` as a Cursor/workspace boot-intent file, not as a Codex
startup source that is guaranteed to be auto-injected.

At the start of a fresh Codex session in this repo, before substantive work,
output a short:

`Agent: Codex (OpenAI)`

followed by:

`Instruction sources in effect:`

Include:
- `AGENTS.md`
- project `.codex/config.toml`
- any framework docs or `.cursor/rules/*.mdc` files actually loaded after this
  bootstrap step
- do not claim `.cursorrules` or `.cursor/rules/*.mdc` were startup-injected
  unless that is directly evidenced in the session

## Working Contract

1. Preserve the user's target. Do not silently replace it with a safer-but-different milestone.
2. Research before novel execution. If the repo and authoritative docs have not been checked, do not improvise.
3. Prefer idempotent Ansible roles, modules, inventories, and playbooks over shell or PowerShell scripts.
4. For Ansible capabilities, prefer a single user-facing lifecycle control point such as `role_name_state: present|absent`. If install and uninstall are asymmetric, keep the interface state-based and hide the asymmetry behind internal present/absent paths.
5. Treat bootstrap work as bootstrap. Do not disguise one-time or semi-manual setup as steady-state configuration management.
6. Before meaningful changes, be able to state:
   - Apply
   - Verify
   - Undo
   - Change class: idempotent config, bootstrap/semi-manual, or destructive
7. When corrected, update the repo guidance so the correction persists.
8. At architecture moments, offer a concise draft plan instead of waiting indefinitely for an explicit planning request.
9. When commands, playbooks, or tools produce output, inspect that output before guessing at failure causes. Do not make speculative retry or tuning changes unless the available evidence supports them.
10. One-off remote teardown or cleanup commands against provisioned hosts require explicit user approval and must be treated as a scoped exception, not the default automation path.
11. When syntax checks, lint, idempotence checks, or runtime verification are not run, say so explicitly in the final output and state why they were skipped or unavailable.
12. During active implementation, required live state queries against the target system should be treated as normal execution, not as optional permission checkpoints. Ask only when the action is destructive, carries hidden side effects, or depends on unresolved user intent.
13. Non-destructive Git housekeeping during active work should be treated as normal execution. Ask only for destructive Git actions or actions with hidden history consequences.
14. The first time a solution introduces or materially changes host targeting, filtering, or exclusion logic, require a read-only target-verification step before the first mutating run. That preview should show what is in scope, what is excluded, and why. If the capability also selects a subresource such as a disk or interface, the preview should show the selected candidate and the selection basis too.
15. When a role or capability exposes a lifecycle interface such as `present|absent`, the owning playbook must preserve that interface instead of wrapper-filtering it down to only one state. Let the role handle the internal present/absent split.
16. When the repo already points to a more scalable pattern, recommend that pattern plainly instead of presenting it as merely optional. For distinct capabilities that can coexist, prefer playbook composition with meaningful tags over merged roles or wrapper roles by default.
17. When the user approves implementation, **execute**, or **go with recommendations and execute**, completing repo files alone is **PROHIBITED** as execute-complete. The agent MUST run preview/read-only verification with captured output, then mutating apply (playbooks, MCP, SSH) for each capability in scope, unless the user explicitly defers live apply in the same thread. If a prerequisite fails, cite probe output. **PROHIBITED** summary label: `operator-controlled` or `not applied live` when the user requested execute and gave no explicit deferral.
18. **Implemented capability default (Ansible only):** When the user asks you to implement a new capability, set host-level gates to **enabled** (`*_enabled: true`, `*_state: present`) unless the user opts out or a documented upstream prerequisite is missing (probe evidence required). Role `defaults/` may stay conservative; **host_vars** for commissioned hosts should reflect enable-when-built. **Plans are not Ansible:** plan packets do not use `present|absent`; operationalizing a plan happens only when the user tells you to implement that plan. Do not retroactively flip unrelated inventory to `present`.
19. **Idempotent desired state:** Re-running automation should converge out-of-state resources toward inventory desired state. `absent` is for explicit teardown or capabilities not yet commissioned — not the default for newly implemented work.
20. **Plan verification is comprehensive:** When executing or completing a plan under `docs/plans/`, build a Plan verification receipt per `docs/codex_framework/plan-verification-receipt.md` — obligation inventory for the full plan packet (change contract, reference tables, prose gates, dependencies), not only `## Checklist` rows. Do not mark `lifecycle: implemented` or call execute-complete on checklist-only evidence, pending rows, or blocked rows that remain inside current scope.
21. **Runtime env artifacts are real managed outputs:** When an implemented capability needs runtime environment variables or secret-backed config files, render the real artifact from the repo’s vault/inventory sources of truth and verify required keys after deployment. Do not treat `.env.example`, placeholders, or demo stubs as the primary delivered surface for an implemented capability.
22. **NetBox-scoped completion is Declared / Applied / Verified:** For plans with `netbox_scope: true`, or plans that touch NetBox-managed naming, services, registry, DNS intent, or ingress metadata, completion requires a `## Mandatory NetBox slice` plus receipt evidence for Declared, Applied, and Verified surfaces. Bootstrap or recovery of NetBox itself is an allowed exception area, but it must be labeled explicitly as bootstrap/recovery work and cannot be reported as normal steady-state NetBox completion.
23. **On-deck user decisions are binding plan obligations:** When the user explicitly says to do something, approves a direction, or decides a scope item during planning, add it immediately to the bottom of the active plan packet under `## On Deck — user decisions to integrate`. This section is a holding bay only while another slice is being edited or the work spans multiple plans. Before any related plan proceeds to build/execute, every on-deck item must be integrated into the relevant plan scope/checklist/receipt, routed to a named sibling plan with dependency linkage, or explicitly rejected with the user's later correction. Do not use "first executable path" or similar sequencing language to narrow away user-approved scope; sequencing may order execution, not remove planned model lanes, agent types, resources, or obligations.
24. **Coordinator does not stop at missing scaffolding:** When the user says to build/execute a plan family, the coordinator must resolve missing repo resources as work, not as a stopping point. Before reporting a blocker, the agent must: inspect existing repo surfaces; consult authoritative docs/MCPs for the missing technology; add or extend the repo-owned Ansible role/playbook/schema scaffolding where the path is clear; encode dependency order in an executable orchestration playbook or documented playbook chain; run the first safe preview/read-only gate; and update receipts with pass/block evidence. A blocker is valid only after that research/scaffolding/probe path has run and the evidence shows a real upstream or live-state prerequisite failure.
25. **Independent validator is a send-back gate:** For multi-plan execution, a coordinator summary is not enough. The independent-validator role must review whether every planned obligation is implemented, blocked with evidence, or moved to a named future plan via `moved_to_plan`. If the validator finds open in-scope work without evidence, the work returns to the coordinator; the agent must keep working rather than end on its own convenience boundary.
26. **Dependency order belongs in automation too:** If a plan family has runtime dependencies, encode them in Ansible entrypoints, not only prose. Umbrella plans should have a matching orchestrator playbook or playbook chain that preserves order such as storage/catalog → GPU prerequisite validation → runtime → gateway → observability → client/profile validation. Do not leave dependency order only in README tables when implementation has begun.
27. **Blocked is not complete:** `blocked` or `fail` can be honest status, but it is not completion. A plan with blocked in-scope obligations must stay `incomplete-wip` or `incomplete` unless the blocked work is removed from current scope, moved to a named future plan with `moved_to_plan`, and the user accepts that narrower scope. Do not use "blocked with evidence" as a loophole to call a requested build done.
28. **Validator/tool failure is not an escape hatch:** If a subagent, validator, MCP, or command times out or fails, narrow the scope, retry with a smaller prompt or direct repo commands, and record the failure as evidence. Do not end the turn merely because the validating tool failed. If validation is impossible after narrowing, leave the plan unsigned and state the exact missing validation.
29. **Intent-integrity sweep before final:** Before a final response on plan execution or framework repair, review the changed plan text for decisions that weaken the user's stated target: "first path" wording that hides the full scope, exact resource picks without research, repo-only work presented as live execution, optionalized user decisions, or pending rows marked as success. Fix those before summarizing.
30. **Research quality for candidate resources:** For brainstorm/intake imports, exact model IDs, provider routes, hardware placement, NetBox object additions, and download plans require a current research matrix and live probe evidence before they are treated as selected. Without that, use `pending_research` or `provisional_example`, keep candidate families visible, and do not download, pin, or mark the row stronger than research-pending.
31. **Reusable multi-agent workflows live in the framework registry:** When the user asks for a coordinator, validator, permission grantor, multi-agent split, or reusable working pattern, document the reusable workflow under `docs/codex_framework/agent-workflows/` instead of burying it only in a plan packet. A plan may select a workflow pattern, but the pattern owns the role boundaries, gates, fallback behavior, and completion rule.
32. **Ansible-first interpretation (default):** Treat user requests to install, download, configure, deploy, remove, or verify homelab resources as requests to do that work **through this repo's Ansible framework** (roles with `present|absent`, playbooks, inventory). Do **not** use ad-hoc SSH/WinRM one-liners, scp'd temp scripts, or manual `pip install` on managed hosts unless the user explicitly says the change is a **one-off** / `oneoffs` exception, **or** you are already debugging Ansible task code interactively to discover a working command that will be placed into the role. Before any novel implementation, research via Context7, Firecrawl, pre-downloaded HRL library entries, Ansible module docs, and existing repo roles/playbooks. For install/mutate work, enter via skill `homelab-ansible-first-entry` (`bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py`) before inventing an approach. **Entry door:** for install/mutate work, run `bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py` and follow skill `homelab-ansible-first-entry` before inventing an approach. For install/mutate starts, enter skill `homelab-ansible-first-entry` first (`bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py`) so routing happens before inventing an approach.

## Repo Truths

1. `*-win` is the bootstrap and control surface for Windows-first operations.
2. The Linux companion side is created and configured through `*-win`.
3. Use **connection surfaces defined per inventory hostname** — see `inventory/hosts_mapping.yaml` and `docs/reference/connection-surfaces.md`. Do not assume WSL, `wsl.exe`, or `*-wsl` hostnames for server or Hyper-V lane work.
4. `linux_vm_hosts` are SSH-ready Hyper-V Ubuntu guests; Windows control hosts use `windows_hosts` with OpenSSH primary and WinRM secondary unless a play targets WinRM explicitly.
5. Existing scripts in `bin/` are bootstrap helpers unless explicitly replaced by repeatable Ansible automation.
6. Older brainstorming or history docs are background context unless explicitly referenced or promoted into the active rule/process layer.
7. Treat `.aiignore` files as repo advisory context boundaries. They are not a
   substitute for `AGENTS.md`, `.gitignore`, or access control, and not every
   tool may enforce them natively. When a path is listed in `.aiignore`, do not
   bulk-read, summarize, or spend context on it unless the user explicitly
   references that path or the active task directly depends on it.
8. Bootstrap docs, bootstrap playbooks, and bootstrap helper scripts are first-touch machine-setup material by default. Do not treat them as the default source for steady-state operation, troubleshooting, or day-2 implementation unless the task is explicitly about initial setup, rebuild, or bootstrap-path changes.
9. For repo-local Python, Ansible, and WinRM-sensitive shell work, use `bin/codex-env <command> ...` or another repo-owned wrapper that explicitly loads the same environment. Do not invoke those commands through raw shell, raw Python, or ambient PATH assumptions. `bin/codex-env` is a **general command** runner (`codex-env python …`, `codex-env ansible …`). Do not assume other repos' `bin/*-env` wrappers share that shape — `gs-env` / `hrl-env` are python-only (see global skill `repo-env-wrapper-contract`).
10. On macOS, if a repo-local query would launch Python or Ansible in a separate MCP/runtime path that does not provably load the repo `.envrc` and project `.venv`, treat that path as unsafe by default. Prefer a `bin/codex-env` shell command or another repo-owned wrapper instead. This guard exists to avoid WinRM worker-dead failures and Python fork crashes from missing environment variables.
11. For controller-side manual SSH to managed hosts, prefer the repo-managed SSH alias that matches the inventory host name, such as `HOM-LAB-HVH-02` or `dev-workstation-win`, instead of jumping straight to raw `ansible_host`, physical hostname, or machine NetBIOS name. In this repo, `ansible_host` may be a WinRM/control-plane target while the SSH alias carries the intended OpenSSH path and client options. **Required skill:** `homelab-ssh-alias-connect` — run `bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py --host <inventory_hostname>` then `ssh <inventory_hostname>`. Do not invent `user@ip` / `-i` / `-p` connection strings.
12. When showing commands for the user/operator to run, present the canonical
    project command form such as `ansible-playbook ...`. Keep Codex-specific
    wrappers, sandbox temp vars, or local runtime workarounds out of
    user-facing commands unless the user explicitly asks for the exact command
    Codex must use from inside its sandbox.
13. NetBox is the source of truth for host, VM, IP, platform, role, and site
    facts. The active naming schema under `docs/reference/naming-standards/`
    is the source of truth for naming patterns, compact codes, and context
    fields. Before naming an object, embedding metadata in a name, or adding a
    custom field, apply the schema files and the gates in
    `framework-netbox-modeling.mdc`:
    - native field before custom field
    - tag before custom field
    - compact schema code equals slug for repo-controlled code objects
    - object hierarchy: Site → Cluster → VM; Site → Device
    - IPs belong to interfaces, not directly to objects
14. For project-maturity work, keep the knowledge gates modular:
    - Ansible automation design uses `ansible-knowledge-gate`
    - NetBox source-of-truth modeling uses `netbox-knowledge-gate`
    - broad project improvement uses `project-maturity-router` to activate one
      or both gates without merging them into one capability
15. The former network-server Windows control alias is retired. Do not
    introduce new active inventory, playbook, or plan references to the retired
    alias. The current reconciled naming target for that control-plane Hyper-V
    host is the compact schema shape `HOM-LAB-HVH-01`; any live NetBox
    object still using an older long form is transitional until the NetBox seed
    reconciliation pass is complete.
16. NetBox identity/modeling changes are not complete until the repo is updated
    and `scripts/validate_netbox_repo_consistency.sh` passes. Run the gate
    directly or through `ansible-playbook playbooks/deploy_ipam_netbox.yaml
    --tags ipam_netbox_repo_consistency`. Do not leave NetBox live state ahead
    of inventory, playbooks, active docs, or repo guidance.
17. The repo-local preview path for NetBox-scoped packet enforcement is
    `bin/netbox-authority-gate.sh`. Use `--static-only` for packet/governance
    checks and the default mode for full read-only reconciliation artifacts.

## Research Expectations

1. Inspect existing playbooks, roles, docs, inventory, and rules before proposing new structure.
2. Check official docs for Codex/OpenAI, Ansible, or other primary systems when the task is new, unstable, or easy to get wrong.
3. When the task involves the OpenAI API, ChatGPT Apps SDK, Codex, Codex configuration, `AGENTS.md` customization, MCP usage, or subagents, use the `openaiDeveloperDocs` MCP server by default without waiting for the user to ask explicitly.
4. Look for a real module, collection, or role before falling back to scripting.
5. If a topic is too novel or under-researched, stop short of a decision-complete plan and escalate to research first.
6. The research output should be a concise evidence summary with:
   - what already exists
   - what sources were checked
   - viable options
   - recommended path
   - key tradeoffs or risks
   When sources are checked during a turn, include a compact final section named
   `Sources checked:` listing each consulted repo file, MCP/doc source, or
   external URL with a short label. This final section is required for both
   research-only answers and implementation summaries that relied on sources.
7. Keep research in the conversation by default unless the user explicitly wants a durable artifact or the result is itself a durable process change.
8. When repeated implementation attempts stop producing new evidence, stop iterating blindly and switch to documentation/source-backed research before changing strategy.
9. When password passing, privilege escalation, or installer flow behaves unexpectedly, inspect the actual module/tool documentation or source before changing escalation strategy.
10. When gathering repo context for a non-bootstrap task, prefer steady-state roles, deploy/verify playbooks, diagnostics notes, and active framework guidance before bootstrap docs or first-touch setup paths. Pull bootstrap material only when the task is explicitly about initial machine setup, bootstrap recovery, or replacing a bootstrap path.
11. When the repo already documents a required runtime wrapper or environment-loading path for Python, Ansible, WinRM, or MCP-adjacent work, follow that documented path instead of calling the underlying interpreter directly.
12. When importing brainstormed, AI-generated, or externally drafted work where
    capabilities/needs are defined but exact resources are not, treat the gap as
    a required research-and-probe slice before implementation. Do not pin model
    IDs, runtime placement, hardware assumptions, NetBox metadata, download
    lists, or Ansible defaults from the brainstorm alone. First collect
    source-backed expert research for the domain and read-only live evidence for
    the target lab surface, such as GPU inventory/VRAM, host reachability,
    existing services, NetBox modeled state, and repo inventory. Exact resource
    identifiers may be preserved as examples only when labeled as
    `provisional_example` or `pending_research`; they are not selected
    candidates until the research matrix compares alternatives, records license
    and operational fit, and links the live probe evidence. Plans produced from
    such intake must show the research/probe receipt or explicitly keep the
    slice blocked/pending.
13. **No invented host targeting before research + classify.** Before writing
    `hosts:` patterns, `when:` placement, or playbook limits for a new/changed
    capability: (a) research existing inventory groups, `policy/*.yml`, and HRL
    capability-selector docs; (b) run or cite
    `playbooks/classify_homelab_hosts.yaml` for in-scope hosts; (c) place via
    matched `execution_roles` / `hardware_classes` / `*_state`, never bare
    hostnames such as `HOM-LAB-HVH-02`. If a host has selector structure but
    matches no role, extend `policy/execution_roles.yml` or
    `policy/coverage.yml` — do not invent around the gap.
14. **Product capabilities (Open WebUI-class):** use skill
    `homelab-product-capability-flow`. Library vendor scrape defaults to
    **task-scoped** (goal-only); full/complete vendor clone only when the user
    asks. Plan after library evidence. Mental model:
    `policy/execution_roles.yml` = match vocabulary; inventory = thin host
    facts + `*_state`; `classify_host` derives roles; `*_state: present`
    commissions.

## Framework Rule Adherence

Framework rule files are compatible with Codex and follow the naming shape:

- `framework-{scope}-{friendly-name}.mdc`

The `scope` segment identifies what the rule family applies to, such as a
project type, language, domain, or capability area.

After the bootstrap step, explicitly load all active framework rules that match
the current work scope. In particular, load the relevant
`framework-{scope}-*.mdc` files plus any supporting rule files they
depend on.

Framework rule files are a normal part of the active instruction stack in this
repo, not optional background notes. When `AGENTS.md` points to them, agent
behavior defined in those files must be followed.

Those framework files may define:
- MCP server tool usage
- reference-doc usage
- agent role behavior
- implementation/modification guidance
- troubleshooting and evidence behavior

Keep the durable rule-loading contract here in `AGENTS.md`. Keep narrower
implementation comparisons, experiments, and stress-test notes in
`docs/codex_framework/` unless the bootstrap itself depends on them.

## Researcher MCP Checkpoints

When the question is about current environment truth, diagnostics, or runtime
capability, prefer these MCP checks instead of reasoning from memory:

1. Ansible environment, Python env, installed collections, or toolchain health:
   - `ansible.ade_environment_info`
   - `ansible.adt_check_env` when ADT health is the question
2. Inventory truth or host/group membership:
   - `ansible-mcp.inventory_graph`
   - `ansible-mcp.inventory_find_host`
   - `ansible-mcp.inventory_parse` when needed
3. Live host state and diagnostics:
   - `ansible-mcp.ansible_gather_facts`
   - `ansible-mcp.ansible_service_manager`
   - `ansible-mcp.ansible_fetch_logs`
   - `ansible-mcp.ansible_diagnose_host`
4. OpenAI/Codex/MCP/config questions:
   - `openaiDeveloperDocs`

Repo-local macOS exception:
- if the question can be answered either by an Ansible/Python MCP tool or by a
  repo-local shell command wrapped with `bin/codex-env`, prefer the wrapped
  shell command for Python-, Ansible-, and WinRM-sensitive checks
- use the MCP path only when the MCP server itself is the subject of the
  question or when there is no equivalent wrapped repo command

These MCP checkpoints are not optional when they directly answer the current
planning or research question. If they are skipped, say why.

## Planning Behavior

1. Use a light planning signal such as `Planner/Steward view:` or `Here's what I've got:`.
2. The default planning output at an architecture moment is:
   - a short recap
   - a short draft plan
   - `Apply / Verify / Undo / Change class`
3. Ordinary planning prose and official plan surfaces are not the same thing.
   The governed plan classes in this repo are only:
   - stored plan packets under `docs/plans/**`
   - official conversational plan surfaces such as `<proposed_plan>` or a
     rendered `Plan` card
4. If the content is still a sketch, summary, or incomplete thought, keep it
   as normal prose. Do not use a plan-card or `<proposed_plan>` surface as a
   design-summary escape hatch.
5. Official plans, including conversational `<proposed_plan>` plans and stored
   plans under `docs/plans/`, must include the conversational-plan minimum:
   - clear title
   - brief summary
   - `Capability Packet Boundary` when grouped capability work is proposed
   - `Apply / Verify / Undo / Change class`
   - an `Architecture/Structure Diagram` via the project diagram routing
     ([docs/codex_framework/architecture-diagram-routing.md](docs/codex_framework/architecture-diagram-routing.md)):
     prefer global skill `create-diagrams` with **SVG** default; fenced Mermaid
     allowed when Mermaid is preferred or already established for that diagram
   - a `Capability Routing Diagram` when routing or branching matters (same
     medium rules)
   - a `Naming/Modeling Diagram` when names, routes, targets, or ownership
     change (same medium rules)
   - `Diagram Inventory`
   - explicit assumptions/defaults
   - enough implementation detail to be decision-complete
6. Before emitting a conversational `<proposed_plan>` or saving a plan under
   `docs/plans/`, run the plan diagram gate:
   - Architecture/Structure is present as **pack artifacts** (linked `.py` +
     SVG, optional drawio/mmd via exporter skills) **or** a fenced Mermaid
     diagram when Mermaid is the intentional medium
   - the diagram shows repo structure, external resources, data/control flow,
     naming schemes, variable sources, tags, and playbook/file organization
     relevant to the plan
   - any conditional diagrams required by the active framework rule are present
   - the final section is `Diagram Inventory` or `Other Available Diagram
     Types`
   - that final section lists diagrams included, medium used, and other
     diagrams that could be created
   If this gate fails, do not emit or save the plan. Fix the plan first.
   Authority: `docs/codex_framework/architecture-diagram-routing.md` and
   `docs/plans/README.md` Required Diagram Checklist.
7. Refine the draft until agreement instead of treating planning as one-shot.
8. Keep draft plans in the conversation until they are accepted. Store approved plans under `docs/plans/` as the canonical durable artifact and mirror them to a GitHub issue as a higher-level roadmap when GitHub is available. New approved plans must be stored as folder packets: `docs/plans/YYYY-MM-DD--short-slug/README.md`. Do not create new single-file plan artifacts.
9. At meaningful role transitions, briefly label the active framework surface when it helps the user track the work:
   - `Planner/Steward view:`
   - `Researcher view:`
   - `Executor view:`
   - `Outcomes:`
10. Reserve `Evidence:` for collected outputs, saved artifacts, and source-backed findings. Use `Outcomes:` or plain implementation prose for change summaries, recaps, or results that are not proof artifacts.
11. Treat Ansible task states such as `changed`, `ok`, and play recap counts as outcomes, not evidence, unless the underlying output, exception text, registered result, log/event entry, or saved artifact is also shown.
12. Use those labels at transition points and decision points, not on every message.

## Implementation Shape

Prefer, in order:

1. Extend an existing role or playbook
2. Compose distinct capability-focused roles in a playbook and expose selective runs through meaningful playbook tags when one combined operation is desired
3. Add a new role or playbook that fits the repo structure
4. Add a narrow helper script only when declarative automation is not a fit

## Trust Rule

When the user identifies a structural concern:

1. stop defending the current path
2. acknowledge the mismatch
3. realign to the user's target
4. continue with a smaller, better-grounded next step
