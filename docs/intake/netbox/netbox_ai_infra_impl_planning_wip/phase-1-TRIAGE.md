# Phase 1 triage — route outcomes

**Status:** Phase 1.3 / 1.4 — `done` (routes **confirmed** by [ASSESSMENT.md](./ASSESSMENT.md) Phase 0.5)  
**Syntheses:** [Group A](./phase-1-GROUP-A-product-lab-intent-synthesis.md) · [Group B](./phase-1-GROUP-B-infra-deployment-synthesis.md)  
**Tracker:** [_wip.md](./_wip.md)

---

## Routing legend

| Route | Meaning | Repo destination |
|-------|---------|------------------|
| **implement-now** | Ready for Phase 2 plan packet after quick Phase 0 confirm | `docs/plans/YYYY-MM-DD--slug/README.md` |
| **incomplete** | Good shape but SSOT / prerequisite / live state gap | `docs/plans/YYYY-MM-DD--slug-incomplete/README.md` |
| **future-state** | Keep direction; no near-term execute | `docs/plans/YYYY-MM-DD--slug-future-state/README.md` |
| **extract** | Patterns or vocabulary only | `docs/intake/` or `docs/reference/` |
| **defer** | Already covered by active plan | Link only; no new packet |

---

## Group B — infra / Ansible (from synthesis)

| ID | Topic | Route | Buildability | Target / link |
|----|-------|-------|--------------|---------------|
| B-01 | Multi-GPU lane model (5090 / 2nd / 3rd) | **incomplete** | blocked | Infra plan; edge-dev host naming |
| B-02 | `ai_huggingface_client` role | **incomplete** | needs gap | Subslice — extend `hfc` / vault |
| B-03 | `ai_nvidia_runtime` verify | **incomplete** | needs gap | Extend `llm_compute_windows` + validate playbook |
| B-04 | `ai_vllm_runtime` primary (5090) | **incomplete** | blocked | [k3s-vllm-service-publication-incomplete](../../../plans/2026-05-28--k3s-vllm-service-publication-incomplete/README.md) |
| B-05 | `ai_vllm_runtime` secondary GPU | **incomplete** | blocked | Same packet as B-04 |
| B-06 | `ai_ollama_runtime` | **incomplete** | needs gap | Subslice of infra plan |
| B-07 | `ai_litellm_gateway` aliases | **incomplete** | needs gap | Extend `k3s_litellm_gateway` |
| B-08 | Langfuse trace metadata contract | **extract** + **incomplete** | needs gap | [1.4.0](./1.4.0-langfuse-cookbook-patterns-REFERENCE.md) + gateway vars |
| B-09 | `ai_ide_client` (Mac/Cursor/OpenClaw) | **incomplete** | needs gap | `deploy_development_nodes` |
| B-10 | `ai_privacy_policy` | **future-state** | blocked | future-state packet |
| B-11 | `ai_ripi_dashboard` V0 | **future-state** | blocked | future-state packet |
| B-12 | `ipam_netbox_ai_services` seed | **incomplete** | needs gap | Extend `ipam_netbox` when URLs stable |
| B-13 | Node class inventory vocabulary | **extract** | repo-ready (extract) | [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) |
| B-14 | Implementation order (steps 1–10) | **incomplete** | blocked | Parent infra incomplete plan |

### Group B — reference-only archives (not triaged as work items)

| Archive | Route | Note |
|---------|-------|------|
| 1.0.0 | **extract** | Parent context + constraints — Phase 0 terminology input |
| 1.1.0 | **extract** | Architecture / operating mode — Phase 0 docs + layer model |
| 1.4.0 | **extract** | Langfuse cookbook patterns — observability slice |

---

## Group A — product lab intent (from synthesis)

| ID | Topic | Route | Buildability | Target / link |
|----|-------|-------|--------------|---------------|
| A-01 | Lab identity: AI product engineering | **extract** | repo-ready (extract) | README + [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) |
| A-02 | Trust / eval / evidence dashboard | **future-state** | blocked | `…--ai-product-eval-dashboard-future-state/` |
| A-03 | Evaluation engineering (golden cases, rubrics) | **future-state** | blocked | future-state packet |
| A-04 | HD-01 Harmonic Work Domain | **extract** | repo-ready (extract) | intake until schema decision |
| A-05 | HWC-01 Harmonic Execution Cell | **extract** | repo-ready (extract) | intake until schema decision |
| A-06 | RAG / memory (heavy) | **future-state** | blocked | future-state packet |
| A-07 | Enterprise multi-agent orchestration | **defer** | defer | — |
| A-08 | Fine-tuning / adaptation | **future-state** | blocked | future-state packet |

---

## Cross-group dependencies

```text
Group A product work (dashboard, eval, RIPI UX)
        ↓ depends on
Group B runtime + gateway + observability (B-04–B-09)
        ↓ depends on
Phase 0 SSOT (hosts, naming, existing k3s roles truth)
```

**Recommended Phase 2 plan order (confirmed post–Phase 0):**

1. **Infra incomplete** packet — multi-GPU + ansible roles + NetBox services (merge B table)  
2. **Extend** k3s-vllm-service-publication-incomplete where overlap  
3. **Product future-state** packet — Group A themes (no execute until infra baseline)  

---

## Phase 1 exit checklist

| Check | Status |
|-------|--------|
| Group A merged | `done` |
| Group B merged | `done` |
| Every B-xx / A-xx row has one route | `done` |
| Reference archives labeled extract | `done` |
| Phase 0.5 buildability confirms routes | `done` — [ASSESSMENT.md](./ASSESSMENT.md) |

**Phase 1** may be marked `complete` in [_wip.md](./_wip.md).

---

## Suggested plan slugs (Phase 2 — not created yet)

| Provisional slug | Route source | Type |
|------------------|--------------|------|
| `2026-05-29--ai-homelab-gpu-litellm-ansible-incomplete` | B-01–B-14 (infra) | incomplete |
| `2026-05-29--ai-product-engineering-lab-future-state` | A-02–A-06, A-08 | future-state |
| *(extend existing)* `2026-05-28--k3s-vllm-service-publication-incomplete` | B-04 overlap | incomplete |

Phase 0 exit criteria met — Phase 2 may create packets; live NetBox seeds on vLLM/Ollama still blocked per `ASSESSMENT.md` decisions.
