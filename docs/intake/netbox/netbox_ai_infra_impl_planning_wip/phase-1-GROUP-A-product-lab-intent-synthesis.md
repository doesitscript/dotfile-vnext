# Phase 1 synthesis — Group A (product lab intent)

**Status:** Phase 1.1 complete  
**Sources:** `2.0.0`, `2.1.0`, `2.2.0`, `2.3.0` (ai-ansible-llm-plus-planning)  
**Not inlined:** `1.0.0`, `1.1.0` (different project; see Phase 0 for vocabulary / architecture crosswalk)

---

## Shared question (all four exports)

What **type of development work** should the homelab support to build **product features** vetted in past conversations — not “train foundation models first”?

**Consensus answer:** **AI product engineering lab** — build, test, observe, evaluate, and govern AI-assisted workflows around models; do not center the lab on ML research or custom model training at first.

---

## Product themes recovered from chat (not repo-verified)

Features and themes repeatedly mentioned across the four exports:

| Theme | Description |
|-------|-------------|
| AI-assisted dashboards | Product UI over LLM-backed workflows |
| Trust / eval / “lie detector” | Really: **trust, evaluation, and evidence dashboard** — not a bespoke ML classifier first |
| Local / private LLM workflows | Sensitive reasoning stays on-prem |
| Prompt + agent evaluation | Quality, regression, governance checks |
| Observability & trace review | What the model did, with evidence |
| Retrieval / memory / RAG | Own data, later heavier investment |
| Governance | Public vs private reasoning, approval posture |
| Human-in-the-loop review | Before promoting outputs to “production” habits |

---

## Lab identity (merged)

| Posture | Detail |
|---------|--------|
| **Primary** | AI product engineering — applications, dashboards, APIs, eval harnesses |
| **Secondary** | LLM runtime literacy (serve, route, observe — not train) |
| **Explicitly not primary yet** | Foundation model training; enterprise multi-agent orchestration; public SaaS |

**HD-01 (from 2.3.0):** “Harmonic Work Domain” — governed private/local AI product engineering extending existing Ansible homelab, vLLM lane, NetBox discipline, LiteLLM strategy.

**HWC-01 (from 2.3.0):** “Harmonic Execution Cell” — focused cell for turning conversation ideas into runnable local features.

---

## Development work types (deduplicated across 2.0.x)

| # | Work type | What it includes | Overlaps Group B infra? |
|---|-----------|------------------|-------------------------|
| 1 | **LLM runtime development** | vLLM, Ollama/llama.cpp experiments, LiteLLM routing, HF cache, model storage | **Yes** — Group B owns deployment map |
| 2 | **AI application development** | Dashboards, APIs, scoring, workflows, prototypes | Partially — needs runtime + observability |
| 3 | **Evaluation engineering** | Golden cases, rubrics, judge models, regression, governance checks | Langfuse + datasets; see `1.4.0` patterns |
| 4 | **Observability / traces** | Langfuse, Postgres, optional ClickHouse/Redis, review UI | **Yes** — already on k3s-02 in estate narrative |
| 5 | **Data + evidence layer** | Eval libraries, prompt/result history, governance metadata | Future-heavy; not bootstrap blocker |
| 6 | **Dashboard / product UI** | Comparison screens, drill-down, operator views | Product slice; no Ansible role yet |
| 7 | **Agent / tool workflows** | Coding agents, tool calls, bounded automation | OpenClaw named in Group B; policy gates required |
| 8 | **Governance & safety** | Privacy classification, promotion receipts | Cross-cuts LiteLLM aliases + Langfuse metadata |

---

## Stack mentions (conceptual — verify in Phase 0)

| Layer | Tools named in Group A |
|-------|-------------------------|
| Inference | vLLM (5090), optional Ollama |
| Gateway | LiteLLM |
| Observability | Langfuse |
| Data | Postgres, ClickHouse, Redis, MinIO (as needed) |
| Operator | Mac dev / IDE (Cursor) |

---

## Conflicts / duplicates across the four exports

| Topic | Resolution in this synthesis |
|-------|-------------------------------|
| Depth of stack list | 2.1.0 is richest capability map; 2.0.0 is clearest “categories”; 2.2.0 splits runtime vs dashboard; 2.3.0 adds HD-01/HWC-01 naming |
| Naming HD-01 / HWC-01 | Treat as **candidate schema/domain labels** until Phase 0 checks `docs/reference/naming-standards/` |
| Same question, four answers | Intentionally parallel perspectives — this file is the single merged view |

---

## What Group A does *not* decide

- **Where** each service runs (host placement) → Group B synthesis  
- **Which Ansible roles** to create → Group B synthesis  
- **GPU lane constraints** (5090 vs second GPU jobs) → `1.0.0` reference  
- **Layer separation** (runtime vs catalog vs control plane) → `1.1.0` reference  

---

## Source map

| Archive ID | Original title | Unique contribution |
|------------|----------------|---------------------|
| 2.0.0 | Lab Setup for AI Development | Six development categories; product vs ML framing |
| 2.1.0 | AI Product Engineering Lab | Full capability map; trust dashboard definition |
| 2.2.0 | AI Product Engineering Lab (name correct) | Runtime vs product/dashboard split; implementation surfaces |
| 2.3.0 | AI Product Lab Setup | HD-01 / HWC-01 governed domain blueprint |

---

## Next step (Phase 1.3)

See [phase-1-TRIAGE.md](./phase-1-TRIAGE.md) for per-topic routing. Group A topics are mostly **future-state / gap-first** until runtime infra (Group B) and Phase 0 SSOT pass land.
