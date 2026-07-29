---
name: Ollama Targeting and Cleanup
overview: "Three-phase plan: (1) initial targeting/cleanup, (2) pre-build research — Ollama primary, Ansible findability (docs/Galaxy/CLI/web) + Context7, HRL persist, recommend/scaffold skills for dotfile-vnext, (3) revise and execute build."
todos:
  - id: r0-ollama-windows-native-pattern
    content: "PRIMARY: What Ollama recommends for Windows background runtime; whether installer/config can create service or scheduled task"
    status: completed
  - id: r5b-ollama-installer-behavior
    content: "PRIMARY: Stock OllamaSetup.exe + any config/startup entries vs standalone zip; service/task/tray/env/PATH only from Ollama docs/artifacts"
    status: completed
  - id: r5i-nssm-ansible-install-pattern
    content: "SECONDARY: community.windows.win_nssm + Chocolate/Chocolatey nssm; Context7/Galaxy when MCP works"
    status: completed
  - id: r5j-context7-galaxy-community-windows
    content: "USE Context7 (MCP recovered): resolve + query community.windows / ansible.windows / ollama / chocolatey for win_nssm win_service win_scheduled_task win_firewall_rule"
    status: completed
  - id: r10-ansible-surface-to-module-discovery
    content: "Durable gate: operational surfaces → Context7/Galaxy module discovery BEFORE any Ansible implement; strengthen ansible-knowledge-gate; forbid script-first"
    status: completed
  - id: r7-default-thin-zero-receipt
    content: "Make Exists/Missing/precise Research Needed the default when library topic checks are thin or zero; wire into HRL AGENTS.md + skill/framework"
    status: completed
  - id: r9-conversation-research-to-library
    content: "Global skill conversation-research-to-library + plan intermission wiring (partner-process + hrl-library-index-entry)"
    status: completed
  - id: r11-ansible-findability-research
    content: "Research how humans find Ansible modules/roles (docs, Galaxy, CLI, community); Context7 + web/Medium + official Ansible findability guides"
    status: completed
  - id: r12-ansible-findability-hrl-persist
    content: "Persist findability research into HRL; feed recommendations into skill designs"
    status: completed
  - id: r13-recommend-dotfile-skills
    content: "From findability + this conversation: recommend and (on execute) scaffold a few skills for dotfile-vnext Ansible workflows"
    status: completed
  - id: b-rocm-standalone-in-role
    content: "Pin ollama-windows-amd64.zip + ollama-windows-amd64-rocm.zip URL/sha256/size in windows_ollama_runtime defaults; install via windows_artifact_download — no one-off downloads"
    status: pending
  - id: b-nssm-in-role
    content: "NSSM wrap path in windows_ollama_runtime present/absent via win_nssm + chocolatey/package nssm — Ansible-only"
    status: pending
  - id: b-dns-reachability-ansible
    content: "B3 DNS/HTTP verify + fix via homelab_hosts_file + k3s_coredns_homelab_hosts + role verify tasks; troubleshooting playbook tags — no one-off curl fixes"
    status: pending
  - id: r6-persist-hrl-research
    content: "Persist ALL conversation research into HRL via global skill conversation-research-to-library; Context7 packs preferred over WebFetch drafts"
    status: completed
  - id: r1-context7-win-service
    content: Context7 lookup for ansible.windows.win_service parameters and patterns
    status: completed
  - id: r2-context7-win-firewall
    content: Context7 lookup for community.windows.win_firewall_rule (or ansible.windows equivalent) parameters
    status: completed
  - id: r3-context7-win-scheduled-task
    content: Context7 lookup for community.windows.win_scheduled_task; compare to service approach
    status: completed
  - id: r4-ollama-env-windows
    content: "Research how OLLAMA_HOST=0.0.0.0 is set persistently on Windows (machine env vs service args)"
    status: completed
  - id: r5-nssm-dotfile-check
    content: Search dotfile-vnext for existing NSSM Ansible patterns; record present or absent
    status: pending
  - id: r5c-startup-runkey-vs-task
    content: "Research Windows Startup-folder / Run-key auto-start vs scheduled task vs service (HRL agent gap)"
    status: pending
  - id: r5d-ollama-windows-ops-surfaces
    content: "Research OLLAMA_MODELS/ORIGINS, logs, LAN bind, lifecycle on Windows; hydrate thin HRL windows.md"
    status: pending
  - id: r5e-role-execution-time-limit
    content: "Check windows_ollama_runtime sets execution_time_limit PT0S (docs default 72h kills long-running serve)"
    status: completed
  - id: r5f-autocomplete-after-hvh-absent
    content: "Research where code-autocomplete-1.5b/code-fast go after HVH-01 Ollama gone (GTX 1060 CC 6.1 blocks vLLM)"
    status: pending
  - id: r5g-vllm-admission-long-term
    content: "Research longer-term fix for UnexpectedAdmissionError GPU race + FreeDiskSpaceFailed on k3s-02"
    status: pending
  - id: r5h-ollama-desktop-dns
    content: "SUPERSEDED by b-dns-reachability-ansible — DNS verify/fix is Ansible playbook/role work"
    status: cancelled
  - id: r6a-hrl-windows-ollama-runtime-pack
    content: "HRL pack: Windows Ollama runtime (installer tray vs standalone+NSSM, env, logs, LAN bind)"
    status: completed
  - id: r6b-hrl-ansible-win-scheduled-task-pack
    content: "HRL pack: win_scheduled_task boot/SYSTEM/PT0S for long-running serve"
    status: completed
  - id: r6c-hrl-ansible-win-service-nssm-pack
    content: "HRL pack: win_service + community.windows.win_nssm for wrapping ollama serve"
    status: completed
  - id: r6d-hrl-ansible-win-firewall-pack
    content: "HRL pack: win_firewall_rule for Ollama :11434"
    status: completed
  - id: r6e-hrl-qa-boot-vs-service
    content: "HRL Q&A: scheduled task vs NSSM service for headless Ollama on Windows"
    status: completed
  - id: r6f-hrl-continue-500-health-note
    content: "HRL/investigation note: Continue 500 via LiteLLM→dead Ollama backends (2026-07-29 probe)"
    status: completed
  - id: r6g-hrl-vllm-admission-disk-note
    content: "HRL/investigation note: vLLM UnexpectedAdmissionError GPU race + FreeDiskSpaceFailed"
    status: completed
  - id: r6h-hrl-host-targeting-ollama-vs-vllm
    content: "HRL note: Ollama only on windows_amd_gpu_hosts; HVH-01 container path; GTX 1060 CC 6.1"
    status: pending
  - id: r8-context7-comprehensive-topic-check
    content: "Require Context7 resolve-library-id + topic-oriented query-docs when hydrating thin topics; document in HRL research workflow"
    status: completed
  - id: a1-hvh01-state-absent
    content: "Set windows_ollama_runtime_state: absent in inventory/host_vars/hom-lab-hvh-01.yaml"
    status: pending
  - id: a2-run-absent-playbook
    content: Run deploy_hvh01_secondary_model_runtime.yaml to remove Ollama from HVH-01 (destructive — requires approval)
    status: pending
  - id: a3-blank-ollama-api-bases
    content: Blank HVH-01 Ollama api_base vars in inventory/host_vars/hom-lab-ctl-k3s-02.yaml
    status: pending
  - id: a4-update-lane-contract
    content: "Update lane contract entries for code-autocomplete-1.5b and code-fast to state: blocked"
    status: pending
  - id: a5-redeploy-litellm
    content: Re-deploy LiteLLM gateway to remove dead Ollama routes
    status: pending
  - id: b1-diagnose-desktop-ollama
    content: SSH into dev-workstation-win and check if role was ever applied (scheduled task, contract JSON)
    status: pending
  - id: b2-deploy-desktop-ollama
    content: "Run deploy_dev_workstation_ollama_runtime.yaml only after Phase 2 validates the role pattern (or after role fix)"
    status: pending
  - id: b3-verify-desktop-ollama
    content: Verify Ollama running, reachable from LiteLLM, and continue-edit model works
    status: pending
  - id: c1-hrl-windows-ollama-guide
    content: Expand HRL implementation-guides/ollama/install-and-operate.md Windows section from Phase 2 evidence only
    status: completed
  - id: c2-hrl-qa-boot-startup
    content: Create HRL q-and-a entry for Windows Ollama boot startup from Phase 2 evidence only
    status: completed
  - id: d2-disk-pressure-note
    content: Document FreeDiskSpaceFailed K3s node warning for future cleanup
    status: completed
  - id: d-research-disk-live
    content: "Part D research: live disk probe k3s-02 + HVH-02; Context7 eviction docs; HRL persist; rewrite Part D with managed vs unmanaged + capacity options"
    status: completed
  - id: d-capacity-followon
    content: "Sibling plan: F: data-drive root for Ansible/Hyper-V VHDX on all Windows hosts with F:data; migrate HVH VHDXs; grow k3s-02; no Jupyter changes"
    status: pending
  - id: e1-hvh01-metadata-fix
    content: Reconcile HVH-01 ai_host_profile with absent state
    status: pending
  - id: e3-secondary-runtime-plane
    content: Check if secondary_model_runtime plane on HVH-01 should be updated after Ollama removal
    status: pending
isProject: false
---

# Ollama Host Targeting, Cleanup, and Operational Docs

## Workflow (three phases)

```text
1. Initial planning (sketch — targeting, HVH-01 remove, desktop keep, LiteLLM routes)
        |
        v
2. PRE-BUILD INTERMISSION
   a. Research (Context7 primary when available; vendor/Firecrawl as needed)
   b. Persist findings into HRL (global skill conversation-research-to-library)
   c. Feed Exists/Missing/decisions BACK into this plan → revise Phase 3
        |
        v
3. Lock BUILD PLAN (Parts A–E) from HRL receipts, then execute
```

**Hard rule:** Research first → persist to HRL → revise plan from evidence → then build. Do not treat Parts B/C as build-ready until Phase 2 exits. Part A still waits if route/backend decisions depend on Phase 2 (e.g. autocomplete placement).

### How we fix “skip research / lose chat findings” (answer to Untitled-1)

**Best approach = combination, not skills alone or project alone.**

| Layer | What | Why |
|---|---|---|
| **Plan structure** | Every non-trivial plan uses Phase 2 intermission: research checklist → HRL persist → revise build steps | Stops coordinators locking build before evidence |
| **Global skill** | `conversation-research-to-library` — capture planning-time findings into HRL with provenance | Stops “researched in chat, never entered the library” |
| **HRL project gate** | `AGENTS.md` + thin/zero Exists/Missing/Research Needed receipt; Context7 hydrate when thin | Makes library checks comprehensive by default |
| **dotfile-vnext pointer** | `hrl-library-index-entry` (or partner-process note) points at the global skill + intermission pattern | Project sessions discover the habit without inventing a parallel skill |

Skills alone are not enough (agents skip skills). Plan structure alone is not enough (findings die when the chat ends). Project-only docs alone are not enough (same failure across repos). **All three.**

When research/planning is needed mid-thread: run Phase 2 shape (checklist → Context7 → persist via skill → update plan recommendations), then continue build planning. Do not jump to Phase 3 edits from memory.

### Context7 — use it (MCP recovered)

As of 2026-07-29 probe: Context7 MCP is **available** again (`/ansible-collections/community.windows` resolved). Phase 2 **must use Context7** for Ansible collection/module lookups and for Ollama library topics when resolvable. Do **not** prefer WebFetch workarounds unless MCP fails again — then label the failure and use emulated packs.

Required Context7 calls in Phase 2 (at minimum):

- `resolve-library-id` + `query-docs` for `/ansible-collections/community.windows` (`win_nssm`, `win_scheduled_task`, `win_firewall_rule`)
- `resolve-library-id` + `query-docs` for `ansible.windows` (`win_service`)
- `resolve-library-id` + `query-docs` for `ollama` (Windows install / serve / env) when library ID resolves
- Persist hits via HRL `context7-topic-pack` (or emulated only if resolve fails)

---

## Phase 1 — Initial planning snapshot (already done)

Four parallel research agents established:

- `windows_ollama_runtime` **implements** boot task, firewall, model pull, absent cleanup — not yet proven as the long-term pattern
- Both hosts have `windows_ollama_runtime_state: present` but Ollama is not running on either
- HOM-LAB-HVH-01 should **not** run Ollama (Docker/K8s present; `ai_host_profile` host_local already retired)
- `dev-workstation-win` is the correct Ollama host (AMD GPU, no container orchestration)
- HRL has catalog/vendor/thin Windows content — **zero** operational Windows service/boot/firewall guidance
- vLLM `UnexpectedAdmissionError` was a transient GPU race; `replicas: 1` is already correct

Quick repo note (not a substitute for Phase 2): role uses `win_environment` + `community.windows.win_firewall_rule` + `community.windows.win_scheduled_task`. Grep found no NSSM in `dotfile-vnext`. Other roles use `ansible.windows.win_service` for OpenSSH/Docker/shares.

---

## Phase 2 — Pre-build intermission (research before build)

**Purpose:** Close every gap the researchers named (HRL + role + targeting + vLLM + live probes). Persist evidence into HRL. Produce machine-checkable decisions (boot pattern; autocomplete home after HVH-01 Ollama absent; vLLM admission mitigation). **Then** update/lock Phase 3 build steps.

### Research priority (user correction)

**Primary question (Ollama-owned):** What does **Ollama** recommend for running on Windows in the background? Does `OllamaSetup.exe`, any config file, Start Menu entry, tray app, or documented setting create or offer a **Windows Service**, **scheduled task**, or other auto-start mechanism? What does the **standalone CLI zip** path document for system-service use?

Ansible module research (`win_scheduled_task`, `win_service`, `win_nssm`) is **secondary** — how we would implement whatever Ollama recommends (or a deliberate alternative), not the authority for what Ollama itself sets up.

### Pre-Ansible module discovery (you don’t need to know FQCNs)

**Problem:** Operators often know the *job* (“run Ollama at boot”, “open port 11434”, “install a Windows service wrapper”) but not the Galaxy/community module names. Agents then invent long `win_shell` / PowerShell scripts inside roles — the failure mode you want to stop.

**Existing repo pieces (not enough alone):**

- Skill `ansible-knowledge-gate` already requires a **module matrix** before `win_shell` / install scripts
- Coding standards say prefer modules over shell
- Agents still skip this when the plan never names the discovery step

**Fix = combination (same pattern as research-first):**

| Layer | What to put in the plan / durable surfaces |
|---|---|
| **Plan Phase 2 gate** | Before any Ansible build step: list **operational surfaces** in plain language (no FQCNs required from you) |
| **Context7 intent lookup** | For each surface, run `resolve-library-id` with a *task* query (e.g. “Ansible Windows scheduled task at boot as SYSTEM”), then `query-docs` — Context7 ranks collections; you do not need to know `win_scheduled_task` first |
| **Module matrix receipt** | Table: surface → candidate FQCN(s) → Context7/`ansible-doc` evidence → use module / use Galaxy role / shell only with justification |
| **Strengthen `ansible-knowledge-gate`** | Add explicit “intent → Context7 → FQCN” step when the operator did not name modules; prohibit script-first when a module exists |
| **Optional global skill** | `ansible-surface-to-module-discovery` (or fold into `conversation-research-to-library` handoff) — reusable across projects |

**How Context7 bridges the gap (this conversation’s example):**

```text
Plain task: "Windows boot auto-start for a console app"
        |
        v
Context7 resolve-library-id(query=that task, libraryName=community.windows)
        |
        v
Finds /ansible-collections/community.windows
        |
        v
query-docs: scheduled task boot SYSTEM / NSSM service wrap
        |
        v
FQCN candidates: community.windows.win_scheduled_task, community.windows.win_nssm
        |
        v
Module matrix in plan → then implement with modules, not a custom PS script
```

Same for firewall (“allow inbound TCP 11434 on Windows”) → `win_firewall_rule`; package install → Chocolatey/win_package matrix already in the knowledge gate.

**Phase 2 deliverable for this Ollama plan:** produce the module matrix for:

- Boot/headless Ollama runtime (task vs NSSM service — after Ollama-primary research)
- Firewall :11434
- Env persistence (`win_environment` and/or `win_nssm.app_environment`)
- Chocolatey install of `nssm` if NSSM path wins

**PROHIBITED in Phase 3 Ansible work:** scripting the whole Ollama service/firewall/boot setup in `win_shell` when the matrix shows a module. Shell only for evidence probes or documented module gaps.

**Todo `r10`:** Update `ansible-knowledge-gate` (and optionally scaffold a thin global discovery skill) so “I don’t know the module name” still forces Context7 intent search before implementation.

### Phase 2 — Ansible findability research (how people are *supposed* to find things)

**Goal of this slice:** Learn the normal human path from “I need to do some tasks” → finding modules/roles/collections (CLI + web + Galaxy + community), then design **a few skills for `dotfile-vnext`** that encode that path so agents stop scripting setups from scratch.

**Research checklist (`r11`) — do before recommending final skill shapes:**

1. **Official Ansible docs — “how to find”**
   - Galaxy user guide / searching Galaxy
   - Collection index / module index navigation
   - `ansible-doc` / `ansible-galaxy` CLI discovery (`search`, `info`, `collection list`, `doc -l` / filters)
   - Any “Developing / Using collections” guidance on choosing Galaxy content vs writing your own
   - Community.windows / ansible.windows collection READMEs (what they claim to cover)

2. **Context7 library check (MCP available — use it)**
   - `resolve-library-id` for Ansible core docs, Galaxy-related docs, `ansible.windows`, `community.windows`
   - `query-docs` queries shaped like: “how to search Galaxy for modules”, “ansible-doc find module”, “choose collection vs custom module”
   - Persist useful hits as HRL Context7 packs under something like `generated/context7/ansible/findability-*`

3. **Web / Medium (and similar) articles**
   - Search for how practitioners find Ansible modules and Galaxy roles (CLI + website)
   - Prefer medium-depth how-tos over listicles; capture 3–5 source-backed patterns
   - Topics to cover even if not in the original Ollama research:
     - Galaxy search UI vs `ansible-galaxy search`
     - When to prefer `ansible.builtin` / `ansible.windows` vs `community.*`
     - How to evaluate a Galaxy role (stars, downloads, maintenance, idempotence)
     - Anti-pattern: reinventing with shell when a module exists

4. **Ansible resources beyond the first pass**
   - ansible.com / docs.ansible.com navigation for “modules”, “collections”, “Galaxy”
   - Forum / docs “Finding modules” style pages if they exist
   - Any HRL-existing Ansible findability content (check catalog first)

**Outputs (`r12` + `r13`) — DONE 2026-07-29:**

- HRL: `q-and-a/ansible/task-idea-to-module.md`, `generated/context7/ansible/module-findability/`
- Project skill: `.cursor/skills/ansible-surface-to-module-discovery/SKILL.md`
- `ansible-knowledge-gate` updated with findability channel order
- Global `conversation-research-to-library` already shipped earlier

**Recommended skill set (locked):**

| Skill | Job | Home |
|---|---|---|
| `ansible-surface-to-module-discovery` | Surfaces → Context7/ansible-doc → matrix | project (done) |
| `conversation-research-to-library` | Planning findings → HRL | global (done) |
| `ansible-knowledge-gate` | Full receipt + implement gate | project (strengthened) |

| Strengthen `ansible-knowledge-gate` | Enforce matrix + intent→FQCN; forbid script-first | **project** (already exists — extend) |
| Optional: `ansible-galaxy-role-evaluator` | Score/shortlist Galaxy roles when a whole capability exists upstream | global or project |

Final skill count and names come **after** findability research — do not scaffold from guesses. Plan execute step: research → HRL → recommend 2–4 skills with clear when/not-when → scaffold approved ones (`scaffold-global-skill` and/or project `create-skill` / `_template`).

- **Repo:** `global-skills`
- **Scaffold:** `bin/gs-env scripts/new_global_skill.py documentation conversation-research-to-library` (via skill `scaffold-global-skill`)
- **Proposed name:** `conversation-research-to-library`
- **When to use:** During or at the end of Plan mode / research intermissions, when conversation findings (probes, WebFetch/docs, Context7, subagent Exists/Missing lists) must not be lost and must land in HRL with provenance
- **Workflow sketch:**
  1. Inventory conversation findings not yet in HRL (paths + one-line claim each)
  2. For each: choose artifact class (Context7 pack / emulated pack / Firecrawl page / Q&A / investigation note / guide thicken)
  3. Write with `decision.yaml` / SOURCE provenance; label Context7 MCP failures honestly
  4. Rebuild indexes when catalog/durable docs change
  5. Emit Exists/Missing/Research Needed if any surface stayed thin
- **Handoffs:** HRL `context7-topic-pack`, `emulated-context7-pack`, `conversation-to-knowledge` (HRL), `validate-library-metadata`, `global-skill-runtime-bridge`
- **First use:** Persist this conversation’s backlog (`r6a`–`r6h`) by invoking the new skill

Do not bury this only in the Ollama plan — the skill is the durable fix for “research done in chat, never entered the library.”

### HRL inventory the agent already mapped (exists vs missing)

**What exists**

- `catalog.yaml` — full `ollama` entry (vendor, Context7, Firecrawl, implementation paths)
- `indexes/technologies.md` — Ollama listed; `wsl2-gpu-models` cross-link
- Vendor: `vendor/ollama/SOURCE.md`, `vendor/ollama/README.md`
- Firecrawl seed: `generated/firecrawl/ollama/docs-seed-2026-07-23/` (thin `pages/windows.md`)
- Context7: 6 packs under `generated/context7/ollama/`
- Guides: `implementation-guides/ollama/install-and-operate.md` (Windows = one line); thin `recipes.md`
- Q&A: `q-and-a/ollama/how-do-i-install-ollama-with-gpu.md`
- Other: `models/_shared/runtime-ollama/README.md`, onboarding notes, `playbooks/validation/validate-ollama.md`

### What's missing (research gaps) — from HRL agent

1. Windows service registration patterns (NSSM, `sc.exe`/`New-Service`, `win_service`, Ollama-as-service vs tray app)
2. Windows boot startup patterns (`win_scheduled_task`, Startup folder / Run key, Ollama auto-start)
3. Windows firewall Ansible patterns (`win_firewall_rule`, port 11434)
4. Ollama Windows operational guide (env vars, logs, LAN bind, lifecycle)

### Full researcher-identified research inventory (all agents → Phase 2)

Promote every gap the researchers named into the checklist. Do not leave any as flavor text.

| Source agent | Gap / question | Phase 2 item |
|---|---|---|
| HRL Ollama | Tray vs service; NSSM vs sc/New-Service vs scheduled task | #1 |
| HRL Ollama | Context7 `win_service` parameters | #2 |
| HRL Ollama | Context7 `win_firewall_rule` parameters | #3 |
| HRL Ollama | Context7 `win_scheduled_task`; task vs service | #4 |
| HRL Ollama | Persistent `OLLAMA_HOST=0.0.0.0` | #5 |
| HRL Ollama | NSSM patterns in `dotfile-vnext` | #6 |
| HRL Ollama | Startup folder / Run key vs task/service | #9 |
| HRL Ollama | Thin Windows ops: `OLLAMA_MODELS`, `OLLAMA_ORIGINS`, logs, LAN bind, lifecycle | #10 |
| HRL Ollama + interim docs | Stock installer vs standalone+NSSM | #7 |
| Ansible win_service See also | NSSM Ansible install pattern docs | #15 |
| Role agent | Role present but process/task missing on both hosts — why (never applied vs failed vs tray fight) | covered by B1 + #7/#1 |
| Role + interim docs | `execution_time_limit` default 72h may kill long-running `ollama serve` via task | #11 |
| Targeting agent | After HVH-01 Ollama absent, where do `code-autocomplete-1.5b` / `code-fast` live? GTX 1060 is Pascal CC 6.1 — **vLLM wants CC ≥ 7.5** | #12 |
| Targeting agent | `ai_host_profile` says host_local retired while ollama state present — reconcile after research | Phase 3 E1 (depends on #12) |
| vLLM agent | Longer-term fix for GPU `UnexpectedAdmissionError` race (not just delete stale pod) | #13 |
| vLLM agent | Node `FreeDiskSpaceFailed` / image GC pressure | #13 |
| Live probe | `ollama-desktop.hom.lab` DNS/reachability from Mac and from LiteLLM pods | #14 |
| Process fix | Thin/zero Exists/Missing/Research Needed default + Context7 hydration | #16–#17 |

### Research checklist (must complete before Phase 3 lock)

**Primary (Ollama):**

1. **Ollama Windows native / recommended pattern** — From Ollama docs and installer artifacts only: tray vs service; does Setup create a service or scheduled task; any config that enables them; standalone zip + NSSM wording
7. **Stock installer vs standalone zip** — Confirm Setup does not register SCM/Task Scheduler; document what “runs in the background” means (tray); what standalone path enables for system service
10. **Ollama Windows operational surfaces** — `OLLAMA_MODELS`, `OLLAMA_ORIGINS`, logs, LAN bind (`OLLAMA_HOST`), tray quit/relaunch; hydrate thin `pages/windows.md`

**Secondary (Ansible / Galaxy — how we implement):**

2. **`ansible.windows.win_service`** — Context7/docs (when MCP works)
3. **`community.windows.win_firewall_rule`** — Context7/docs
4. **`community.windows.win_scheduled_task`** — Context7/docs; boot/SYSTEM; `PT0S` time limit
5. **`OLLAMA_HOST` persistence under Ansible** — machine env vs `win_nssm` `app_environment`
6. **NSSM already in `dotfile-vnext`?** — grep present/absent
15. **`community.windows.win_nssm`** — module docs + Chocolatey `nssm` install; Context7/Galaxy collection lookup when MCP works
15b. **Context7 library IDs** — `resolve-library-id` for `community.windows`, `ansible.windows`, `chocolatey` / Galaxy docs; `query-docs` for `win_nssm`, `win_service`, `win_scheduled_task`, `win_firewall_rule` (re-try when MCP registered)

**Other researcher gaps:**

8. Persist all conversation research into HRL (via global skill `conversation-research-to-library` once scaffolded)
9. Startup folder / Registry Run key (alternatives — not Ollama’s documented path)
11. Role `execution_time_limit` PT0S check
12. Autocomplete placement after HVH-01 Ollama absent
13. vLLM admission longer-term + disk pressure
14. `ollama-desktop.hom.lab` DNS/reachability
16. Default thin/zero library receipt in HRL AGENTS.md
17. Context7 comprehensive topic-check habit
18. **Scaffold global skill** `conversation-research-to-library` then use it for r6a–r6h

**Where those Ansible module names came from (not inventing):** The HRL agent was asked to check Windows **service registration**, **boot startup**, and **firewall** patterns for an Ansible-managed Ollama role. Those operational surfaces map to the standard Ansible Windows modules (`win_service`, `win_scheduled_task`, `win_firewall_rule`). Separately, the role research agent already found `windows_ollama_runtime` uses `community.windows.win_firewall_rule` and `community.windows.win_scheduled_task` live. The Context7/docs lookups are to **confirm current parameters** and decide service vs task — not to invent module names from thin air.

### Phase 2 interim evidence (fetched 2026-07-29; early pass used WebFetch while MCP was down — **re-run via Context7 now that MCP recovered**)

**Ollama Windows installer / official docs** ([docs.ollama.com/windows](https://docs.ollama.com/windows)):

- Stock path: `OllamaSetup.exe` installs a **native Windows app** that **runs in the background** (tray / GUI app). CLI on PATH under the user profile. API on `http://localhost:11434`.
- Install does **not** require Administrator; installs under the user home by default.
- Model path via **user** env var `OLLAMA_MODELS` (Control Panel → user env vars); docs say quit tray app and relaunch after changing env.
- Logs under `%LOCALAPPDATA%\Ollama`; binaries under `%LOCALAPPDATA%\Programs\Ollama`.
- Docs do **not** say the stock installer registers a Windows Service or a Task Scheduler task for `ollama serve`.
- Separate **Standalone CLI** zip path: for embedding or **running as a system service via `ollama serve`**, Ollama docs explicitly recommend tools such as **[NSSM](https://nssm.cc/)**.

**Ansible `community.windows.win_scheduled_task`** (module docs):

- Manages Task Scheduler create/modify/remove — not a recommendation essay for “task vs service.”
- Supports **boot** triggers (optional `delay` like `PT1M`), run as `SYSTEM` / `NETWORK SERVICE`, `run_level: highest`, `logon_type: service_account`.
- Official examples include: run PowerShell as NETWORK SERVICE **on boot**; create tasks as SYSTEM.
- Caveats relevant to long-running servers: default `execution_time_limit` is **72 hours** unless set to `PT0S` (infinite) — important if using a task to keep `ollama serve` up indefinitely.

**Ansible `ansible.windows.win_service`** (module docs):

- Manages real SCM services (`start_mode` auto/delayed/manual/disabled, `state` started/stopped/absent, failure actions, username/SYSTEM).
- Creating a service expects a **service-capable executable** (`path`).
- Module **See also** includes **“Install a service using NSSM”** — Ansible’s documented path for wrapping a normal console app as a service.
- Non-service accounts need `SeServiceLogonRight` (via `win_user_right`).

**Implication for Phase 2 decision (not locked yet):**

| Path | Who documents it | Fit for headless LAN `ollama serve` |
|---|---|---|
| Stock `OllamaSetup.exe` tray app | Ollama Windows docs | User-session / localhost-oriented; not a SCM service |
| `ollama serve` + **NSSM** + `win_service` | Ollama standalone docs + Ansible win_service See also | Explicitly recommended for system-service wrap |
| Boot **scheduled task** running `ollama serve` | Ansible win_scheduled_task examples (boot + SYSTEM) | Viable; role already uses this; must set infinite time limit and verify reboot survival |

Repo role today uses scheduled task, not NSSM. Phase 2 must decide whether to keep that, switch to Ollama’s documented NSSM path (`community.windows.win_nssm` + `win_service`), or hybrid — after persisting receipts into HRL.

**Ansible `community.windows.win_nssm`** (module docs, fetched 2026-07-29):

- Installs a Windows service by wrapping an application binary with NSSM (requires nssm ≥ 2.24 via Chocolatey).
- Key params: `application`, `arguments`, `app_environment` (env for the wrapped app — relevant for `OLLAMA_HOST`), `start_mode`, `state`, stdout/stderr files.
- After create with `state=present`, service is **not** auto-started; use `ansible.windows.win_service` to start/configure further.
- This is the concrete Ansible module behind `win_service`’s “Install a service using NSSM” See also — and matches Ollama’s standalone-docs recommendation.

**Context7 MCP status:** Recovered 2026-07-29 (third probe). Library ID confirmed: `/ansible-collections/community.windows`. Phase 2 execution **uses Context7 first** for community.windows / ansible.windows / ollama topic packs. WebFetch interim notes above are draft only until replaced by `context7-topic-pack` receipts. Emulated packs only if a specific `resolve-library-id` fails.

### Phase 2 — HRL entry backlog (conversation research not yet in library)

Nothing below has been written to HRL yet this conversation. **Writing requires Agent mode** (plan-mode mode-switch was rejected 2026-07-29). When build/execute is approved, create these before locking Phase 3 role changes:

| ID | Proposed HRL path | Content to capture (from this conversation) |
|---|---|---|
| r6a | `generated/firecrawl/ollama/windows-runtime-2026-07-29/` + thicken `implementation-guides/ollama/install-and-operate.md` Windows | Stock tray installer; no SCM/service; user env `OLLAMA_MODELS`; logs `%LOCALAPPDATA%\Ollama`; standalone zip + **NSSM** for system service; LAN bind via `OLLAMA_HOST` |
| r6b | `generated/context7/ansible-windows/win-scheduled-task-boot/` (**Context7 pack**) | Boot trigger, SYSTEM/`NETWORK SERVICE`, `execution_time_limit: PT0S` (default 72h), examples |
| r6c | `generated/context7/ansible-windows/win-service-and-win-nssm/` (**Context7 pack**) | `win_service` + `win_nssm` from `/ansible-collections/community.windows` + ansible.windows |
| r6d | `generated/context7/ansible-windows/win-firewall-rule-ollama/` | Inbound TCP 11434 pattern (also cite `windows_ollama_runtime` usage) |
| r6e | `q-and-a/ollama/how-do-i-run-ollama-headless-on-windows-boot.md` | Decision frame: tray vs scheduled task vs NSSM service; cite Ollama + Ansible docs |
| r6f | `notes/investigations/continue-500-litellm-ollama-backends-2026-07-29.md` | Continue→LiteLLM→dead Ollama; Ornith OK; edit/apply/autocomplete timeouts; host_vars drift |
| r6g | `notes/investigations/vllm-unexpected-admission-and-disk-pressure-2026-07-29.md` | 1 GPU, replicas 1, Recreate race; FreeDiskSpaceFailed on k3s-02 |
| r6h | `notes/investigations/ollama-vs-vllm-host-targeting-2026-07-29.md` | `windows_amd_gpu_hosts` only for Ollama; HVH-01 Docker/K8s; GTX 1060 CC 6.1 blocks vLLM; autocomplete placement open |

Also refresh thin HRL `generated/firecrawl/ollama/docs-seed-2026-07-23/pages/windows.md` from the full windows page content retrieved this conversation.

**Do not lose interim plan evidence** — the “Phase 2 interim evidence” section above is the working receipt until HRL packs exist.

### Phase 2 exit criterion

Documented decisions with sources:

1. Boot/runtime pattern: (a) keep scheduled-task, (b) `win_service`, (c) NSSM wrap, or (d) hybrid
2. Autocomplete/`code-fast` placement after HVH-01 Ollama absent (blocked vs move vs other) — respecting GTX 1060 CC limit
3. vLLM admission longer-term mitigation note (or named follow-up plan) + disk-pressure note
4. Thin/zero library receipt default wired into HRL AGENTS.md/skill
5. Ansible findability research complete → HRL note → **recommended skill set for dotfile-vnext** (then scaffold approved skills)

Only then revise Phase 3 Parts A–E (especially A3/A4 route blanking and B2 role fix) and build.

### Phase 2 also — make thin/zero library research the default (durable)

The HRL Ollama agent’s Exists / Missing / Research Needed receipt was good. It must become **default behavior**, not a one-off lucky prompt.

**Problem today:** HRL `AGENTS.md` says retrieve only what the task needs and expand when gaps remain — but it does **not** require a machine-friendly Exists/Missing/precise-gap receipt when surfaces are thin or empty. Coordinators can summarize “docs are thin” and skip a hydratable checklist.

**Required durable changes (do in Phase 2, before claiming library research habits are fixed):**

1. **HRL `AGENTS.md` — Required Research Workflow**  
   Add a mandatory receipt when a technology/topic library check returns thin or zero coverage for the operational surfaces asked about:
   - **What Exists** (catalog paths, vendor, Context7 packs, Firecrawl, guides, Q&A, skills — concrete paths)
   - **What’s Missing** (named surfaces that returned zero or one-line stubs)
   - **Research Needed Before Implementation** (numbered, tool-named: Context7 module/topic, Firecrawl page, vendor page, repo grep)  
   Prohibit ending on vague “docs are thin.”

2. **Context7 as default hydration helper**  
   When a topic is thin/missing and exact product/module syntax matters, agents must:
   - `resolve-library-id` for the product and for Ansible collections when the task is Ansible-managed
   - `query-docs` for the specific operational surfaces (service, firewall, scheduled task, env vars, etc.)
   - Persist useful hits via `context7-topic-pack` (or emulated pack if no library ID)  
   Do not invent module parameters from memory when Context7 can answer.

3. **Skill / framework wiring**  
   Prefer extending existing surfaces rather than inventing a parallel process:
   - Update [`skills/documentation/library-intake-good-shape/`](file:///Users/joshc/develop/homelab-reference-library/skills/documentation/library-intake-good-shape/) checklist/receipt template with an Exists/Missing/Research-Needed section for thin topics
   - Or add a short shared note under [`frameworks/shared/`](file:///Users/joshc/develop/homelab-reference-library/frameworks/shared/) if intake skill is too narrow
   - Mirror a one-line pointer from [`dotfile-vnext/.cursor/skills/hrl-library-index-entry/`](file:///Users/joshc/develop/dotfile-vnext/.cursor/skills/hrl-library-index-entry/) so Cursor sessions enter the same receipt shape

4. **Coordinator rule**  
   When a subagent returns Exists/Missing/Research Needed, those Research Needed items become **Phase 2 todos** automatically — not optional flavor text. This plan’s first miss (skipping the six lookups) is the failure mode to prevent.

**Exit for this durable slice:** AGENTS.md (and chosen skill/framework) updated; one example receipt shape documented; Ollama Windows Phase 2 checklist satisfies the new default.

**Durable slice status (2026-07-29):** Done — HRL thin/zero receipt in `AGENTS.md`; global `conversation-research-to-library`; `plan-research-intermission.md` + partner-process; `ansible-knowledge-gate` intent→Context7→matrix. Remaining Phase 2 is Ollama/findability research + HRL content packs (r0–r6h, r11–r13), not the habit wiring.

### Phase 2 research persist receipt (2026-07-29 — enough to revise build plan)

## Library topic check — Ollama Windows + Ansible Win modules

**Exists:**
- `generated/firecrawl/ollama/.../windows.md` — thin (API port, OLLAMA_MODELS, logs)
- `implementation-guides/ollama/install-and-operate.md` — install cheatsheet only (now expanded)
- Context7 ollama packs (install-platforms, gpu, docs-and-apis) — not Windows headless

**Missing (before this pass):** Windows headless runtime pack; ansible win_nssm/scheduled_task/win_service packs; Q&A boot vs NSSM

**Written this pass:**
- `generated/context7/ollama/windows-runtime-service-vs-tray/`
- `generated/context7/ansible/community-windows-nssm-scheduled-firewall/`
- `generated/context7/ansible/ansible-windows-win-service/` (Context7 thin → ansible-doc)
- `q-and-a/ollama/windows-headless-scheduled-task-vs-nssm.md`
- `notes/investigations/2026-07-29--continue-500-litellm-dead-ollama.md`
- `notes/investigations/2026-07-29--vllm-admission-disk-pressure.md`
- Indexes rebuilt (`bin/hrl-env scripts/build_indexes.py`)

**Research Needed (defer / optional for build lock):**
- Full Ansible findability Medium/docs research (r11–r13) — does not block Part A
- AMD ROCm zip exact Ansible download URL/checksum for desktop
- Autocomplete placement after HVH gone: **recommend block until desktop Ollama verified**, then point LiteLLM api_bases at `ollama-desktop.hom.lab`
- ollama-desktop DNS reachability from LiteLLM pods (r5h) — verify in B3

### Phase 2 decisions (locked for planning / Phase 3 revise)

1. **Boot/runtime:** Prefer **standalone zip + `community.windows.win_nssm`** for always-on LiteLLM backend (vendor service-integration path). Stock Setup.exe = tray/login item only.
2. **Interim role fix (required before any present deploy):** If keeping scheduled task short-term, set `execution_time_limit: PT0S` on `win_scheduled_task` (docs default 72h). Role currently omits this.
3. **Build sequence recommendation:** Part A (HVH absent + blank LiteLLM HVH bases + block lanes) can proceed after user approval for destructive absent. Part B: diagnose → **role fix (PT0S minimum; NSSM migration preferred)** → deploy desktop → verify → then re-point autocomplete routes.
4. **Module matrix (intent → FQCN):**

| Surface | FQCN | Fit |
| --- | --- | --- |
| Wrap ollama serve as SCM service | `community.windows.win_nssm` | yes |
| Boot headless without NSSM | `community.windows.win_scheduled_task` + `PT0S` | partial |
| Native service binary only | `ansible.windows.win_service` | no alone for ollama.exe |
| Firewall :11434 | `community.windows.win_firewall_rule` | yes |
| Machine env | `ansible.windows.win_environment` | yes |

5. **C1/C2:** Seeded in HRL this pass — Phase 3 C becomes “expand if deploy reveals gaps,” not “write from zero.”

**Phase 2 exit for build planning:** Met for Parts A + B planning revise. Open Research Needed items do not block revising the plan or executing Part A with approval.

---

## Phase 3 — Build plan (revised 2026-07-29 from Phase 2 evidence)

**Hard rule (user 2026-07-29):** Nothing one-off to the side. ROCm zips, NSSM, DNS verify/fix, and runtime install all land in **roles + playbooks** (checksum-pinned artifacts, verify tags, hosts/CoreDNS converge). Manual curl/scp/`oneoffs` only if you explicitly say so.

### Build wave order (dependencies)

```text
Wave 0 — F:`data` Hyper-V storage (shared + unique recommended moves)
         BEFORE Part A: code/inventory first; live VHDX migrate is controlled outage
         (k3s/LiteLLM/Docker brief downtime). Does not depend on Ollama Part A/B.
Wave 1 — Part A HVH-01 Ollama absent + LiteLLM blank/block (needs approval)
Wave 2 — Part B0 role (PT0S/ROCm/NSSM) then B1–B3 desktop Ollama
Wave 3 — Part C tighten HRL after evidence; Part E metadata
         (guest HF grow / prune after Wave 0 host VHDX on F:)
```

**Why Wave 0 first:** Moving VHDXs to F: does not require Ollama teardown; putting it after Part A would leave k3s-02 disk pressure during LiteLLM work. Jupyter: **no change**.

### Wave 0 — F:`data` Hyper-V storage (build now)

**Shared (all Hyper-V Windows hosts with F:`data` — `hyperv_lane_*`):**

1. Inventory: `windows_hyperv_ansible_root` / `windows_hyperv_vm_storage_root` → `F:\ProgramData\Ansible\...`
2. Role defaults: `hyperv_ubuntu_vm` roots off that var (C: fallback only if unset)
3. Playbooks: k3s/docker VHDX defaults use F: root; generalize `hyperv_move_vm_storage.yaml`
4. GPU-P Windows payload temp under `F:\ProgramData\Ansible\...` (not C:)

**Unique recommended migrates (same playbook, host-specific `hyperv_vm_storage_move_targets`):**

| Host | VM | From → F: | start_after |
| --- | --- | --- | --- |
| HVH-02 | `hom-lab-ctl-k3s-02` | D: → F: | true (primary capacity) |
| HVH-02 | `hom-lab-ctl-dkr-02` | C: → F: | true |
| HVH-01 | `hom-lab-ctl-k3s-01` | D: → F: | true |
| HVH-01 | `nsrv-dkr-01` | C: → F: | true (live Docker VM name) |
| HVH-01 | `nsrv-k3s-01` | C: → F: | **false** (Off / legacy) |

**Not automated:** Steam/Games on D:, Jupyter on guest.

### Findability efficiencies applied to this build (r11–r13 done)

| Efficiency | How this build uses it |
| --- | --- |
| Surfaces → module matrix first | `ansible-surface-to-module-discovery` then `ansible-knowledge-gate` for NSSM/ROCm/task work |
| ansible-doc for footguns | `execution_time_limit: PT0S` from ansible-doc, not folklore |
| Prefer modules already in role | Extend `windows_artifact_download` + `win_nssm` / `win_scheduled_task` — do not invent download scripts |
| HRL Q&A | `q-and-a/ansible/task-idea-to-module.md` + `generated/context7/ansible/module-findability/` |
| Skill scaffolded | `.cursor/skills/ansible-surface-to-module-discovery/SKILL.md` |

### Part A — what needs your approval?

**Yes — explicit approval before the destructive live apply on HVH-01.**

Per AGENTS.md (one-off/destructive teardown against provisioned hosts):

| Step | Needs your “go”? | Why |
| --- | --- | --- |
| A1 inventory `windows_ollama_runtime_state: absent` | Soft / included when you approve Part A | Repo desired-state only |
| **A2 run absent playbook** | **Yes — required** | Uninstalls Ollama, removes scheduled task, firewall rule, env, contract on **HOM-LAB-HVH-01** |
| A3 blank LiteLLM api_bases in inventory | Included with Part A approval | Repo config |
| A4 block lane contract | Included with Part A approval | Repo metadata |
| A5 redeploy LiteLLM | Included with Part A approval | Live gateway converge (non-destructive to HVH disk, but changes routes) |

Saying **“approve Part A”** means: do A1–A5 including the **mutating absent playbook on HVH-01**. Repo-only edits without A2 are not a complete Part A.

Ready to plan/execute with the decisions above. Destructive HVH absent still needs that explicit approval.

## Part A — Remove Ollama from HOM-LAB-HVH-01

### A1. Set `windows_ollama_runtime_state: absent` in HVH-01 inventory

File: [inventory/host_vars/hom-lab-hvh-01.yaml](inventory/host_vars/hom-lab-hvh-01.yaml)

Change `windows_ollama_runtime_state: present` to `absent`. This is already consistent with the `ai_host_profile.ai_runtime.host_local.enabled: false` and `engine: none` that the host already declares.

### A2. Run the Ollama absent playbook targeting HOM-LAB-HVH-01

Run `deploy_hvh01_secondary_model_runtime.yaml` which will invoke the role with `state: absent`. The role's `absent.yml` removes: scheduled task, kills processes, firewall rule, env vars, uninstalls via Inno Setup, removes contract dir, optionally purges models.

### A3. Blank the HVH-01 Ollama api_base vars in LiteLLM gateway config

File: [inventory/host_vars/hom-lab-ctl-k3s-02.yaml](inventory/host_vars/hom-lab-ctl-k3s-02.yaml)

- Blank `k3s_litellm_gateway_autocomplete_1_5b_api_base` (was `http://ollama-hvh01.hom.lab:11434/v1`)
- Blank `k3s_litellm_gateway_continue_apply_api_base` (was `http://ollama-hvh01.hom.lab:11434/v1`)

This removes `code-autocomplete-1.5b`, `code-fast`, and `continue-apply` routes from LiteLLM since the Ollama backend is being decommissioned. The `build_helm_values.yml` conditional (`api_base | length > 0`) already handles this — routes simply won't be generated.

### A4. Update the lane contract metadata

File: [roles/k3s_litellm_gateway/defaults/main.yml](roles/k3s_litellm_gateway/defaults/main.yml)

Update `k3s_litellm_gateway_lane_contract` entries for `code-autocomplete-1.5b` and `code-fast` from `state: enabled` to `state: blocked` with reason noting HVH-01 Ollama decommissioned. Keep blocked until Part B verify passes; then optionally re-enable against desktop api_base.

### A5. Re-deploy LiteLLM gateway

Run the LiteLLM deploy playbook to converge the gateway config (routes removed).

## Part B — Fix Ollama on dev-workstation-win (Ansible-only)

### B0. Role changes (same change set as present deploy — edit role, then one present playbook)

All of the following land in [`roles/windows_ollama_runtime/`](roles/windows_ollama_runtime/) + existing [`roles/windows_artifact_download/`](roles/windows_artifact_download/) — **no side downloads, no manual ROCm install.**

1. **`execution_time_limit: PT0S`** on `win_scheduled_task` if task path remains (even briefly).
2. **Standalone + ROCm artifacts (pinned)** — add role defaults for GitHub release `v0.32.3` (same pin family as Setup.exe today):

| Asset | URL pattern | sha256 (v0.32.3) | size |
| --- | --- | --- | --- |
| `ollama-windows-amd64.zip` | releases/…/ollama-windows-amd64.zip | `c66dd7dde4d5ec4822eaa57dd421d51aa7c633a3ff36a974040837df73a5969e` | 1457806156 |
| `ollama-windows-amd64-rocm.zip` | releases/…/ollama-windows-amd64-rocm.zip | `5f7e6af10649db31d78a7d13d68d130faf76bca2a6ab59ae9f572e4f86ce662f` | 245370093 |

   Install path: `windows_artifact_download` (checksum + resume) → extract/publish under managed install root → **not** ad-hoc `Invoke-WebRequest`.

3. **NSSM service path (in role)** — `community.windows.win_nssm` wrapping `ollama.exe serve`, `start_mode: auto`, env via `app_environment` and/or `win_environment`; install nssm via Chocolatey/package module inside the role; absent path removes NSSM service. Prefer this over tray Setup.exe for always-on LiteLLM backends (vendor standalone “service integration”).

4. Keep firewall + healthcheck via existing modules (`win_firewall_rule`, `win_uri`).

### B1. Diagnose (Ansible / role facts — not one-off SSH folklore)

- Prefer read-only Ansible/ad-hoc through inventory SSH alias or a `tags: diagnose` path on the deploy playbook that checks task/service/contract/API.
- Confirm whether present was ever applied vs tray-only install.

### B2. Deploy present

Run `deploy_dev_workstation_ollama_runtime.yaml` **after** B0 role changes are in the tree (one edit session + one apply is fine).

### B3. DNS + HTTP reachability — verify and fix via playbooks/roles

**PROHIBITED:** fixing DNS with one-off `/etc/hosts` edits or curl-only “proof” outside automation.

**Verify (Ansible):**

- Extend deploy/verify path (role tasks or tagged playbook) to assert `http://ollama-desktop.hom.lab:11434/api/tags` from:
  - controller/`mac-dev` (uri module)
  - K3s/LiteLLM path (pod exec or gateway health check task — still playbook-owned)
- Catalog already defines the name: [`inventory/group_vars/all/homelab_hosts_file.yml`](inventory/group_vars/all/homelab_hosts_file.yml) (`ollama-desktop` → `dev-workstation-win` IP).

**Fix when verify fails (Ansible):**

1. Confirm SSOT IP in inventory / `homelab_hosts_file` catalog.
2. Converge [`playbooks/homelab_hosts_file.yaml`](playbooks/homelab_hosts_file.yaml) (mac + linux + windows hosts files + [`deploy_k3s_coredns_homelab_hosts.yaml`](playbooks/deploy_k3s_coredns_homelab_hosts.yaml)).
3. Ensure `k3s_coredns_homelab_hosts_state: present` where LiteLLM pods resolve `*.hom.lab`.
4. Re-run verify tags; only then re-point LiteLLM api_bases to `http://ollama-desktop.hom.lab:11434/v1` and unblock lanes.

**Troubleshooting skill pointer:** `homelab-dns-investigator` for evidence collection; remediations must still be inventory + hosts/CoreDNS playbooks above.

## Part C — Update HRL Library

**Seeded in Phase 2 persist.** Remaining: tighten guide after live B3 evidence; mark Q&A `status: reviewed` when NSSM vs task choice is implemented in the role.

### C1. Update `implementation-guides/ollama/install-and-operate.md`

Windows headless section already expanded from Context7 — append deploy-verified paths after B3; document ROCm zip vars once role lands.

### C2. Q&A for Windows Ollama boot startup

Created: `q-and-a/ollama/windows-headless-scheduled-task-vs-nssm.md` (draft). Promote to reviewed when role matches preferred pattern.

## Part D — Stabilize capacity via F:`data` (research-first; updated knowledge)

**Intent:** Research disk pressure, then encode **shared Windows data-drive placement** so the same playbook pattern applies to **all Windows servers that have an F:`data` volume**. Do not one-off move files. **Do not touch Jupyter** on k3s-02 (explicit user decision).

### D0. Research done this pass (2026-07-29) — evidence

**Hosts probed:** `hom-lab-ctl-k3s-02` (guest), `HOM-LAB-HVH-01`, `HOM-LAB-HVH-02`.

| Fact | Evidence |
| --- | --- |
| k3s-02 root ~**87%** full; VHDX **80G** on HVH-02 **D:** | guest `df`; host VHDX |
| `FreeDiskSpaceFailed` — wants ~5.4Gi unused images, finds **0** | kubelet image GC; all images in use |
| HF PVC claim **120Gi**, used ~**19G** on guest root | local-path under k3s storage |
| Guest GPU-P caches ~**8.1G** | `/var/lib/ansible/hyperv_ubuntu_gpu_p_runtime` |
| Jupyter on guest | **out of scope — leave alone** |
| Both HVHs have labeled **F: `data`** with large free space | Get-Volume probe |

**Free space (2026-07-29):**

| Host | C: free | D: free | F:`data` free | Notes |
| --- | --- | --- | --- | --- |
| HVH-01 | ~180G | ~782G | ~487G | F: already used for `shares` |
| HVH-02 | ~61G | ~29G | ~1013G | D: nearly full (Steam + k3s VHDX); F: best expand target |

**HRL:** Context7 disk-pressure pack + investigation + Q&A; PowerShell SSH quoting pack. Indexes rebuilt.

### D1. Common playbook pattern (all Windows hosts with F:`data`)

Repo already treats F: as the managed data volume (`windows_file_shares_expected_volumes`, `windows_managed_service_data_backup_disk` data letter **F**, HVH-01 artifact paths under `F:\shares\public\...`).

**Target convention (encode once, apply everywhere that has F:`data`):**

```text
windows_data_drive_letter: F          # when volume label == data (or inventory fact)
windows_ansible_data_root: F:\ProgramData\Ansible
hyperv_vhdx_root:          F:\ProgramData\Ansible\hyperv_ubuntu_vm
# Keep F:\shares\public as SMB/public share root (already managed)
```

**Shared move candidates (both servers — same role/playbook logic):**

| Candidate | Why move to F: | Playbook shape |
| --- | --- | --- |
| **Hyper-V VHDX files** currently on C: or D: under `*\ProgramData\Ansible\hyperv_ubuntu_vm\**\*.vhdx` | Sustained VM I/O + growth; lessons-learned already say keep K3s off C:; D: on HVH-02 is full of games | Inventory `*_host_vhdx_path` → `F:\...`; offline VM → move/attach via Hyper-V modules; both hosts |
| **Hyper-V VM config/working trees** still under `C:\ProgramData\Ansible\hyperv_ubuntu_vm\` (tens of GB even when VHDX already on D:) | Config+diff disks inflate C:; same tree layout on both hosts | Default Ansible Hyper-V root → F:; migrate with role |
| **Ansible download/cache trees** (`...\Ansible\downloads`, GPU-P windows payload/temp under ProgramData\Ansible) | Rebuildable caches; F: already holds published artifacts on shares | Stage/cache roots → `F:\ProgramData\Ansible\...` or `F:\staging\...` |
| **Published artifacts** | Already on `F:\shares\public\artifacts\...` (HVH-01) | Keep; make HVH-02 match same layout |

**Do not put on F: via this pattern:** Windows OS, NVIDIA driver ProgramData, Chocolatey (unless separately decided), user profile OS trees, **Jupyter**.

Gate: only hosts where `F:` exists and label/`windows_file_shares_expected_volumes` says `data` (same idea as file-share hosts).

### D2. Unique-to-host move candidates (probe 2026-07-29)

#### HOM-LAB-HVH-01 (storage lane)

| Item | ~Size / location | Unique note | Suggest |
| --- | --- | --- | --- |
| `nsrv-dkr-01.vhdx` | **40G** on **C:** | Legacy/alternate Docker VM still on system disk | Move VHDX (+ prefer VM tree) → **F:** |
| `nsrv-k3s-01.vhdx` | **60G** on **C:** | Off VM; still consuming C: | Move → **F:** or retire if unused |
| `hom-lab-ctl-k3s-01` VHDX | **60G** on **D:** | Already off C:; D: has lots of free | Optional: also standardize onto **F:** for one root |
| `C:\...\hyperv_ubuntu_vm\nsrv-*` trees | ~**90G + 82G** under C: Ansible | Dominates **212G** C:\ProgramData\Ansible | Move with VHDX to F: |
| `F:\shares\public` | ~78G already | Good — keep as share root | No move; grow usage here |

HVH-01 C: is not critically full (~180G free) but **~100G+ of VM disks still on C:** — highest-value common-pattern cleanup.

#### HOM-LAB-HVH-02 (GPU / primary compute)

| Item | ~Size / location | Unique note | Suggest |
| --- | --- | --- | --- |
| `hom-lab-ctl-k3s-02.vhdx` | **80G** on **D:** | D: only **~29G free**; guest disk pressure | **Primary:** move to **F:** then grow VHDX (fixes k3s-02 FreeDiskSpaceFailed capacity path) |
| `hom-lab-ctl-dkr-02` VHDX | **~30G** on **C:** | Docker companion still on C: | Move → **F:** |
| `C:\...\hyperv_ubuntu_vm\` trees | ~**90G** total on C: | VM working dirs + dkr | Move with VHDXs to F: |
| Host GPU-P `C:\...\hyperv_ubuntu_gpu_p_runtime` | **~7G** | Host-side build/payload | Prefer **F:\ProgramData\Ansible\...** or existing `F:\shares\public\artifacts\...` |
| `D:\SteamLibrary` / Games / recordings | **~730G+** on D: | Personal/gaming — **not** Ansible | Out of automation scope unless you later ask; explains why D: cannot absorb VHDX growth |
| `F:\Games` | ~89G already on F: | Non-repo | Leave; proves F: is fine for bulk data |

### D3. Guest (k3s-02) options after host VHDX is on F:

1. Grow guest disk (inventory `hyperv_ubuntu_k3s_vm_disk`) once VHDX lives on F: with headroom.
2. Optionally move HF cache off local-path onto storage share (separate storage-lane plan).
3. Prune guest GPU-P `/var/lib/ansible/...` caches after publish (~8G).
4. Pin vLLM image tag.
5. **Jupyter: no action.**

### D4. Part D exit for *this* Ollama plan packet

- Research (guest + both Windows hosts + F: candidates): **done**
- Live VHDX migrate / F: re-root: **follow-on sibling plan** (`d-capacity-followon`) — Ansible-only, applies to all F:`data` Windows hosts
- Ollama A/B execute does **not** require F: moves first; HVH-02 k3s capacity remains a stability follow-on
## Part E — Metadata Reconciliation

### E1. Fix HVH-01 metadata contradiction

In [inventory/host_vars/hom-lab-hvh-01.yaml](inventory/host_vars/hom-lab-hvh-01.yaml), the `ai_host_profile` already says `host_local.enabled: false` and `engine: none`. After setting `windows_ollama_runtime_state: absent` (Part A1), this contradiction is resolved.

### E2. Verify dev-workstation-win metadata is correct

Confirm `runtime_planes.windows_ollama.enabled: true` and `hardware_classes: [amd_gpu]` — these are the targeting markers that ensure only this host receives Ollama. Already set per research.

### E3. Remove HVH-01 from `secondary_model_runtime` runtime plane if Ollama was the only reason

Check if `secondary_model_runtime` in HVH-01's runtime_planes is solely for Ollama. If so, mark it accordingly.

## Apply / Verify / Undo / Change class

- **Apply**: Part A (after approval) → B0 role (PT0S + ROCm/standalone pins + NSSM) → desktop present → hosts/CoreDNS converge → verify tags → LiteLLM repoint; HRL already seeded; Part D capacity mutations deferred to follow-on (research done)
- **Verify**: Ansible uri/health tags for `ollama-desktop.hom.lab`; HVH absent surfaces gone; LiteLLM routes; no one-off curl as completion proof alone; Part D: HRL investigation + Context7 pack present; FreeDiskSpaceFailed still expected until capacity follow-on
- **Undo**: inventory state flips + LiteLLM api_base restore + role absent
- **Change class**: idempotent inventory/role/playbook + destructive HVH absent (approval) + additive HRL/skills; Part D follow-on may include VHDX grow / storage relocate (bootstrap-ish capacity)
