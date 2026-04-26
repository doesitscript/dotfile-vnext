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
5. active `framework-*` files under `.cursor/rules/`, plus any explicitly
   referenced supporting rule files

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

## Repo Truths

1. `*-win` is the bootstrap and control surface for Windows-first operations.
2. The Linux companion side is created and configured through `*-win`.
3. `*-wsl` is a legacy hostname suffix, not proof of direct readiness.
4. `wsl_hosts` should mean SSH-ready Linux companion surfaces.
5. Existing scripts in `bin/` are bootstrap helpers unless explicitly replaced by repeatable Ansible automation.
6. Older brainstorming or history docs are background context unless explicitly referenced or promoted into the active rule/process layer.
7. Bootstrap docs, bootstrap playbooks, and bootstrap helper scripts are first-touch machine-setup material by default. Do not treat them as the default source for steady-state operation, troubleshooting, or day-2 implementation unless the task is explicitly about initial setup, rebuild, or bootstrap-path changes.
8. For repo-local Python, Ansible, and WinRM-sensitive shell work, use `bin/codex-env <command> ...` or another repo-owned wrapper that explicitly loads the same environment. Do not invoke those commands through raw shell, raw Python, or ambient PATH assumptions.
9. On macOS, if a repo-local query would launch Python or Ansible in a separate MCP/runtime path that does not provably load the repo `.envrc` and project `.venv`, treat that path as unsafe by default. Prefer a `bin/codex-env` shell command or another repo-owned wrapper instead. This guard exists to avoid WinRM worker-dead failures and Python fork crashes from missing environment variables.
10. For controller-side manual SSH to managed hosts, prefer the repo-managed SSH alias that matches the inventory host name, such as `server-225-win`, instead of jumping straight to raw `ansible_host`, physical hostname, or machine NetBIOS name. In this repo, `ansible_host` may be a WinRM/control-plane target while the SSH alias carries the intended OpenSSH path and client options.

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
7. Keep research in the conversation by default unless the user explicitly wants a durable artifact or the result is itself a durable process change.
8. When repeated implementation attempts stop producing new evidence, stop iterating blindly and switch to documentation/source-backed research before changing strategy.
9. When password passing, privilege escalation, or installer flow behaves unexpectedly, inspect the actual module/tool documentation or source before changing escalation strategy.
10. When gathering repo context for a non-bootstrap task, prefer steady-state roles, deploy/verify playbooks, diagnostics notes, and active framework guidance before bootstrap docs or first-touch setup paths. Pull bootstrap material only when the task is explicitly about initial machine setup, bootstrap recovery, or replacing a bootstrap path.
11. When the repo already documents a required runtime wrapper or environment-loading path for Python, Ansible, WinRM, or MCP-adjacent work, follow that documented path instead of calling the underlying interpreter directly.

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
3. Refine the draft until agreement instead of treating planning as one-shot.
4. Keep draft plans in the conversation until they are accepted. Store approved plans under `docs/plans/` as the canonical durable artifact and mirror them to a GitHub issue as a higher-level roadmap when GitHub is available.
5. At meaningful role transitions, briefly label the active framework surface when it helps the user track the work:
   - `Planner/Steward view:`
   - `Researcher view:`
   - `Executor view:`
   - `Outcomes:`
6. Reserve `Evidence:` for collected outputs, saved artifacts, and source-backed findings. Use `Outcomes:` or plain implementation prose for change summaries, recaps, or results that are not proof artifacts.
7. Treat Ansible task states such as `changed`, `ok`, and play recap counts as outcomes, not evidence, unless the underlying output, exception text, registered result, log/event entry, or saved artifact is also shown.
8. Use those labels at transition points and decision points, not on every message.

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
