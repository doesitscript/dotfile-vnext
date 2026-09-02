---
title: AI correction evaluation for codex multi-terminal promotion
evaluated_at: 2026-09-02
evaluated_plan: README.md
status: resolved
superseded_by: ready_for_review_by_evaluator_simple_2026-09-02T112907.md
audience: ai-agent
applied_skills:
  - conversation-task-documentation-auditor
  - design-to-known-future
---

# AI correction evaluation

## Skill selection

There is no dedicated local skill whose scope is "evaluate a plan and correct it."
The closest valid skills for this task were:

- `conversation-task-documentation-auditor`
  Used to turn the promotion work into an itemized evidence audit.
- `design-to-known-future`
  Used because the user explicitly asked for future-proof and scalable correction guidance.

## Scope and source boundaries

Evaluate the current plan packet and its claimed promotion against live repo sources.

Use as evidence:

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md`
- `docs/plans/2026-09-02--codex-multi-terminal-promotion/backup/one-off-source/`
- `roles/codex_homelab_profiles/`
- `roles/fzf_tab_completion/`
- `roles/common/shell_config/`
- `roles/common/bash_completion/`
- `inventory/host_vars/mac-dev.yaml`
- `playbooks/deploy_development_nodes.yaml`
- `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh`

Do not implement from `backup/one-off-source/`. That tree is archival only.

## Executive verdict

The promotion is substantial and mostly real at the repo level:

- one-off artifacts were archived under the plan packet
- managed role-owned replacements exist
- `mac-dev` inventory wiring exists
- the plan now includes a richer execution receipt than the earlier version

The plan packet is still not fully correct as an operational contract. The main defects are:

- undo/removal semantics are false for static `~/.bashrc.d/*.bash` contributions
- apply/update commands are not self-contained for clean-host convergence
- the promotion map does not fully enumerate or disposition every one-off item
- verification evidence is documented inside the plan, but not separated into a stronger durable receipt surface

## Finding summary

| ID | Severity | Status | Title |
| --- | --- | --- | --- |
| P1 | high | resolved | Undo contract is false for static bashrc contributions — role-owned absent paths + live absent converge (EXECUTION-RECEIPT) |
| P2 | high | resolved | Apply and update commands are not self-contained — plan README self-contained rows |
| P3 | medium | resolved | Promotion map is incomplete — full disposition ledger in plan README |
| P4 | medium | resolved | Verification evidence plan-local — EXECUTION-RECEIPT.md split + absent converge section |
| P5 | low | resolved | `shell-completion.bash` YAML frontmatter leak was fixed and recorded |

## Findings

### P1. Undo contract is false for static bashrc contributions

**Observed problem**

The plan says the capability can be undone by setting:

- `fzf_tab_completion_state: absent`
- `codex_homelab_profiles_multi_terminal_state: absent`

and re-running the playbook.

That is not true for the static bash files:

- `roles/codex_homelab_profiles/files/bashrc.d/codex-multi-terminal.bash`
- `roles/fzf_tab_completion/files/bashrc.d/shell-completion.bash`

because `common/shell_config` copies all `roles/*/files/bashrc.d/*.bash` files unconditionally.

**Evidence**

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:36-38`
- `roles/common/shell_config/tasks/unix.yml:93-112`
- `roles/codex_homelab_profiles/tasks/mac.yml:41-45`
- `roles/fzf_tab_completion/tasks/absent.yml:2-20`
- `roles/codex_homelab_profiles/README.md:17-29`
- `roles/fzf_tab_completion/README.md:16-24`

**Why this matters**

This breaks the plan's declared `Apply / Verify / Undo` contract and makes the capability not truly reversible by state toggle alone.
It also makes future extension harder because ownership is split between role state and a generic shell deployment sweep that ignores role state.

**AI correction directive**

Pick one removal model and make every owned artifact follow it:

1. Preferred: make static shell contributions state-aware.
   Example directions:
   - move capability shell files out of the generic unconditional sweep
   - deploy them from the owning role with explicit `present` and `absent` tasks
   - or teach `common/shell_config` to accept a state-aware contribution manifest instead of copying every `files/bashrc.d/*.bash`
2. Update every contract surface after the code change:
   - plan `README.md`
   - `roles/codex_homelab_profiles/README.md`
   - `roles/fzf_tab_completion/README.md`
3. Verify removal explicitly:
   - `test ! -f ~/.bashrc.d/codex-multi-terminal.bash`
   - `test ! -f ~/.bashrc.d/shell-completion.bash`

**Acceptance condition**

After toggling the role states to `absent` and re-running the documented command, no static shell files from this capability remain on the host.

### P2. Apply and update commands are not self-contained

**Observed problem**

The plan's operational commands omit required integration tags:

- `Update behavior` omits both `shell_config` and `bash_completion`
- `Apply` includes `shell_config` but omits `bash_completion`

For clean-host convergence, `fzf-tab-completion` relies on:

- `common/shell_config` to copy `shell-completion.bash`
- `common/bash_completion` to provide the bash-completion loader that the completion stack expects

**Evidence**

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:28-29`
- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:36-37`
- `playbooks/deploy_development_nodes.yaml:140-147`
- `roles/fzf_tab_completion/README.md:16-23`
- `inventory/host_vars/mac-dev.yaml:76-86`

**Why this matters**

A plan packet should be executable from its own documented contract.
If the listed commands only work because the host was already preconditioned, the plan is not future-proof or reproducible.

**AI correction directive**

Make the documented commands fully self-contained for a clean `mac-dev` converge.

Minimum expected correction:

- update `Update behavior` and `Apply` to include `shell_config`, `bash_completion`, `fzf_tab_completion`, and `codex_homelab_profiles`
- or replace tag-level commands with one higher-level documented playbook invocation whose dependencies are explicit

Then add a short note that:

- `common/shell_config` delivers static role `*.bash` contributions
- `common/bash_completion` provides the completion substrate

**Acceptance condition**

A new operator or AI can run the documented command on a clean compatible host and obtain all required files without relying on undeclared prior state.

### P3. Promotion map is incomplete against the archived one-off inventory

**Observed problem**

The archived one-off inventory is broader than the current promotion map.
The map omits several items that were either promoted, retired, or intentionally left without a managed counterpart.

Examples omitted from the map:

- `deploy/codex/instructions-*_one_off_tasks.md`
- `deploy/python/usercustomize_one_off_tasks.py`
- `deploy/scripts/verify_fzf_tab_completion_one_off_tasks.sh`
- `deploy/scripts/verify_python_repl_fzf_tab_completion_one_off_tasks.sh`
- `deploy/uninstall_one_off_tasks.sh`
- `deploy/codex-homelab/desktop_one_off_tasks/config.toml` as a distinct promoted item

**Evidence**

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/backup/one-off-source/README.md:94-107`
- `docs/plans/2026-09-02--codex-multi-terminal-promotion/backup/one-off-source/deploy/install_one_off_tasks.sh:16-57`
- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:54-64`
- `roles/codex_homelab_profiles/tasks/multi_terminal.yml:8-33`
- `roles/fzf_tab_completion/tasks/present.yml:27-49`

**Why this matters**

The plan says promotion was evaluated piece-by-piece.
An incomplete map makes it harder for later agents to tell which pieces were:

- promoted as-is
- promoted with reshaping
- intentionally retired
- still missing

That weakens scalability and future maintenance.

**AI correction directive**

Replace the current promotion map with a full disposition table.

Use these statuses:

- `Promoted`
- `Promoted with reshape`
- `Retired and replaced`
- `Retired with no managed replacement`
- `Open gap`

Each row should include:

- one-off artifact path
- status
- managed destination or replacement
- note on behavior change, if any

Recommended minimum table content:

| One-off item | Expected disposition |
| --- | --- |
| `deploy/bashrc.d/codex-multi-terminal_one_off_tasks.bash` | Promoted with reshape |
| `deploy/bashrc.d/shell-completion_one_off_tasks.bash` | Promoted with reshape |
| `deploy/bashrc.d/python-fzf-tab-completion_one_off_tasks.bash` | Promoted |
| `deploy/python/usercustomize_one_off_tasks.py` | Promoted |
| `deploy/bin/codex-homelab_one_off_tasks.sh` | Promoted with reshape |
| `deploy/scripts/render_local_model_catalog_one_off_tasks.sh` | Promoted with reshape |
| `deploy/codex/local-deep_one_off_tasks.config.toml` | Promoted |
| `deploy/codex/local-fast_one_off_tasks.config.toml` | Promoted |
| `deploy/codex/local-hvh01_one_off_tasks.config.toml` | Promoted |
| `deploy/codex-homelab/desktop_one_off_tasks/config.toml` | Promoted |
| `deploy/codex/instructions-navigation_one_off_tasks.md` | Promoted with reshape |
| `deploy/codex/instructions-implement_one_off_tasks.md` | Promoted with reshape |
| `deploy/codex/instructions-skills_one_off_tasks.md` | Promoted with reshape |
| `deploy/codex/instructions-hvh01_one_off_tasks.md` | Promoted with reshape |
| `deploy/scripts/install_fzf_tab_completion_one_off_tasks.sh` | Retired and replaced |
| `deploy/scripts/install_python_repl_fzf_tab_completion_one_off_tasks.sh` | Retired and replaced |
| `deploy/scripts/verify_fzf_tab_completion_one_off_tasks.sh` | Open gap or retired with explicit rationale |
| `deploy/scripts/verify_python_repl_fzf_tab_completion_one_off_tasks.sh` | Open gap or retired with explicit rationale |
| `deploy/uninstall_one_off_tasks.sh` | Retired and replaced, but replacement contract currently incomplete |

**Acceptance condition**

An AI can read the table and determine the disposition of every archived one-off artifact without consulting chat history.

### P4. Verification evidence is plan-local rather than separated into a stronger receipt artifact

**Observed problem**

The plan now contains detailed execution and verification tables, which is better than the earlier version.
However, the evidence is still self-contained inside the plan `README.md` instead of a separate durable receipt artifact.

**Evidence**

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:66-99`
- related stronger receipt pattern visible in the parent packet:
  `docs/plans/2026-09-01--homelab-local-ai-clients-codex/codex-execution-receipt.md`

**Why this matters**

For AI maintenance, separating:

- the plan intent
- the execution receipt
- the corrective evaluation

produces cleaner authority boundaries and reduces accidental rewriting of historical evidence.

**AI correction directive**

Create a dedicated receipt file in this plan folder if you want stronger long-term maintainability.

Suggested shape:

- `EXECUTION-RECEIPT.md`
  Contains the command runs, host verification checks, manual TTY-only checks, and historical bug-fix note.
- keep `README.md`
  Focus on capability boundary, contract, promotion map, and links to receipt/evaluation artifacts.

This is a medium-priority structure improvement, not a blocker for correctness.

**Acceptance condition**

The plan packet has clear separation between:

- authoritative contract
- historical execution evidence
- corrective evaluation

### P5. `shell-completion.bash` YAML frontmatter leak was fixed and recorded

**Observed problem**

The role file previously had a stray `---` on line 1, which broke `source ~/.bashrc.d/shell-completion.bash`.
The current plan records this and marks it fixed.

**Evidence**

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:92`
- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:98-99`
- current file parses under `bash -n`:
  `roles/fzf_tab_completion/files/bashrc.d/shell-completion.bash`

**AI correction directive**

No further change required for this specific defect unless the packet is being refactored and you want to preserve the historical note in a dedicated receipt file.

## One-off disposition ledger

Use this as the AI-safe source of truth when rewriting the promotion map.

| Archived one-off artifact | Current disposition | Live replacement or note |
| --- | --- | --- |
| `deploy/bashrc.d/codex-multi-terminal_one_off_tasks.bash` | promoted with reshape | `roles/codex_homelab_profiles/files/bashrc.d/codex-multi-terminal.bash` |
| `deploy/bashrc.d/shell-completion_one_off_tasks.bash` | promoted with reshape | `roles/fzf_tab_completion/files/bashrc.d/shell-completion.bash` |
| `deploy/bashrc.d/python-fzf-tab-completion_one_off_tasks.bash` | promoted | `roles/fzf_tab_completion/templates/python-fzf-tab-completion.bash.j2` |
| `deploy/python/usercustomize_one_off_tasks.py` | promoted | `roles/fzf_tab_completion/files/usercustomize.py` |
| `deploy/python/usercustomize_one_off_tasks.py.example` | retired with no managed replacement | archival example only |
| `deploy/bin/codex-homelab_one_off_tasks.sh` | promoted with reshape | `roles/codex_homelab_profiles/templates/codex-homelab.sh.j2` |
| `deploy/scripts/render_local_model_catalog_one_off_tasks.sh` | promoted with reshape | `roles/codex_homelab_profiles/files/render_local_model_catalog.sh` |
| `deploy/codex/local-deep_one_off_tasks.config.toml` | promoted | `roles/codex_homelab_profiles/files/codex-profiles/local-deep.config.toml` |
| `deploy/codex/local-fast_one_off_tasks.config.toml` | promoted | `roles/codex_homelab_profiles/files/codex-profiles/local-fast.config.toml` |
| `deploy/codex/local-hvh01_one_off_tasks.config.toml` | promoted | `roles/codex_homelab_profiles/files/codex-profiles/local-hvh01.config.toml` |
| `deploy/codex-homelab/desktop_one_off_tasks/config.toml` | promoted | `roles/codex_homelab_profiles/templates/desktop-config.toml.j2` via `tasks/mac.yml` |
| `deploy/codex/instructions-navigation_one_off_tasks.md` | promoted with reshape | `roles/codex_homelab_profiles/files/codex-instructions/instructions-navigation.md` |
| `deploy/codex/instructions-implement_one_off_tasks.md` | promoted with reshape | `roles/codex_homelab_profiles/files/codex-instructions/instructions-implement.md` |
| `deploy/codex/instructions-skills_one_off_tasks.md` | promoted with reshape | `roles/codex_homelab_profiles/files/codex-instructions/instructions-skills.md` |
| `deploy/codex/instructions-hvh01_one_off_tasks.md` | promoted with reshape | `roles/codex_homelab_profiles/files/codex-instructions/instructions-hvh01.md` |
| `deploy/scripts/install_fzf_tab_completion_one_off_tasks.sh` | retired and replaced | `roles/fzf_tab_completion/tasks/present.yml` |
| `deploy/scripts/install_python_repl_fzf_tab_completion_one_off_tasks.sh` | retired and replaced | `roles/fzf_tab_completion/tasks/present.yml` |
| `deploy/scripts/verify_fzf_tab_completion_one_off_tasks.sh` | no managed replacement documented | recommend receipt/test surface or explicit retirement note |
| `deploy/scripts/verify_python_repl_fzf_tab_completion_one_off_tasks.sh` | no managed replacement documented | recommend receipt/test surface or explicit retirement note |
| `deploy/install_one_off_tasks.sh` | retired and replaced | playbook/role-driven converge |
| `deploy/uninstall_one_off_tasks.sh` | partially replaced | `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh` plus role `absent` states, but removal contract is currently incomplete |

## Recommended correction order

1. Fix the actual removal semantics in live role code.
2. Rewrite the plan's `Update behavior`, `Apply`, and `Undo` contract so it matches real behavior.
3. Update the two role READMEs so they stop promising false `absent` behavior.
4. Replace the short promotion map with the full disposition ledger.
5. Optionally split plan intent from execution receipt into separate files.

## Suggested AI patch boundaries

When correcting this packet, keep changes inside these ownership boundaries:

- behavior fixes:
  `roles/common/shell_config/`, `roles/codex_homelab_profiles/`, `roles/fzf_tab_completion/`
- inventory and playbook contract:
  `inventory/host_vars/mac-dev.yaml`, `playbooks/deploy_development_nodes.yaml`
- documentation contract:
  this plan folder plus the two role `README.md` files

Do not reintroduce one-off mechanics or restore `_one_off_tasks` naming on the live path.

## Minimal completion checklist for the correcting AI

- The plan's commands are executable and self-contained.
- The undo contract removes every owned artifact.
- The promotion map covers every archived one-off artifact.
- Role READMEs agree with actual code behavior.
- Receipt and evaluation artifacts are clearly separated if the packet is being cleaned up for long-term use.
