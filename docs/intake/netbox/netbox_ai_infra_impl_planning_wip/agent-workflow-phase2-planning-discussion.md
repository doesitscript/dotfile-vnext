# Agent workflow Phase 2 — planning discussion

**Type:** discussion  
**Source:** [1.1.0](./1.1.0-dev-workflow-arch-layers-operating-mode-REFERENCE.md) lines 1212–1224, 1152–1155  
**Parent:** [capability-requirements-to-resources-evaluation.md](./capability-requirements-to-resources-evaluation.md)

Intake says **implement** planner/coder/tester agents. You do **not** have this in Cursor today. This doc plans **what “implement” means** in your repo — without pretending it is already Ansible.

---

## Critical clarification

| Intake wording | What it is NOT | What it IS |
|----------------|----------------|------------|
| “planner agent” | A new Linux service or Ansible role | A **Cursor agent profile** + **Langfuse session** + **LiteLLM alias** + **rules** |
| “implement Phase 2” | Run one playbook | A **bundle of config artifacts** deployed over multiple slices |

---

## Target workflow (unchanged intent)

```text
planner → coder → tester → reviewer → steward
         ↑ human or local-only steward
```

Each step = **one Langfuse session** (or nested traces under one `work_item_id`).

---

## First five “implement” items — plan breakdown

### 1. Planner agent

| Layer | Deliverable |
|-------|-------------|
| **Requirement** | Break work into safe slices; read docs; no code writes |
| **Cursor** | Custom mode: “Planner” — read-only tools; `.cursor/rules` or project rule snippet |
| **LiteLLM** | Default model: `ripi-private` or `code-fast`; virtual key optional |
| **Langfuse** | `metadata`: `agent_role=planner`, `workflow=planning`, `session_id={{ work_item_id }}` |
| **Ansible** | None required for V0 — optional: template `mac-dev` env file with LiteLLM URL |
| **Verify** | One planning prompt → trace in Langfuse with tag `agent:planner` |

### 2. Coder agent

| Layer | Deliverable |
|-------|-------------|
| **Requirement** | Write code on working branch |
| **Cursor** | Default Agent mode; model = `code-deep` via LiteLLM |
| **LiteLLM** | Route `code-deep` → vLLM 5090 |
| **Langfuse** | `agent_role=coder`, link `repo=dotfile-vnext` |
| **Verify** | Small edit task → trace shows generation + model `code-deep` |

### 3. Tester agent

| Layer | Deliverable |
|-------|-------------|
| **Requirement** | Write/run tests; capture output |
| **Cursor** | Agent profile with terminal allowed; pytest/ansible test commands |
| **Model** | `code-fast` (local 7B) — tests rarely need 32B |
| **Langfuse** | `agent_role=tester`, attach test stdout in trace metadata or child span |
| **Verify** | Run one playbook syntax check or pytest → trace + saved log artifact |

### 4. Reviewer agent

| Layer | Deliverable |
|-------|-------------|
| **Requirement** | Review diff; security; missing verify |
| **Cursor** | Review mode / separate chat; no write |
| **Model** | `code-review` (local 7B or Gemini scrubbed) |
| **Langfuse** | `agent_role=reviewer`, tag `promotion_state=candidate` |
| **Verify** | Review a small PR diff → trace |

### 5. Test command capture

| Layer | Deliverable |
|-------|-------------|
| **Requirement** | Evidence of what ran — not “I ran tests” |
| **Mechanism A** | Langfuse trace with `metadata.test_command`, `test_exit_code` |
| **Mechanism B** | Repo artifact: `artifacts/agent-runs/<work_item_id>/test-<timestamp>.log` |
| **Ansible** | Optional collector task (mirror troubleshooting pattern) — **future** |
| **Verify** | File exists + trace links to same `session_id` |

---

## Items 6–8 (defer next slice)

| Item | Tangible plan |
|------|---------------|
| Git diff capture | `git diff` output → artifact + Langfuse attachment metadata |
| Langfuse trace IDs | Store on `AgentRun` when RIPI DB exists; until then: JSON sidecar per work item |
| RIPI run records | future-state app — schema in 1.1.0 (`RipiWorkItem`, `AgentRun`) |

---

## Dependencies (must exist first)

```text
vLLM primary (code-deep)
    → LiteLLM aliases configured
        → Langfuse metadata on proxy + clients
            → Cursor modes documented
                → Phase 2 agent workflow usable
```

**Blocked by:** [capability-requirements-to-resources-evaluation.md](./capability-requirements-to-resources-evaluation.md) §A and §B.

---

## OpenClaw in this workflow

OpenClaw = **coder** or **planner** client (your choice). Point at LiteLLM; use same `session_id` convention as Cursor for Langfuse continuity.

---

## Plan packet outline (when promoted)

**Slug:** `…--cursor-langfuse-agent-workflow-incomplete`

**Checklist (draft):**

- [ ] Metadata contract YAML committed  
- [ ] LiteLLM `model_list` has all §A aliases  
- [ ] Langfuse test trace per agent role  
- [ ] Cursor planner/coder/tester/reviewer docs in repo  
- [ ] Test capture path wired (artifact + metadata)  
- [ ] No scope: RIPI web UI, Notion MCP, Azure Phase 3  

---

Sources checked:
- Intake `1.1.0`, `1.4.0`
- LiteLLM Langfuse metadata docs
- Repo Cursor/framework rules pattern
