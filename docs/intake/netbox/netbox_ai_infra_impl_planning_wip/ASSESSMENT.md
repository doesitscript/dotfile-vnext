# Phase 0 assessment — AI homelab intake vs repo truth

**Status:** Phase 0 complete (2026-05-29)  
**Tracker:** [_wip.md](./_wip.md)  
**Inputs:** Phase 1 syntheses, [phase-1-TRIAGE.md](./phase-1-TRIAGE.md), parallel repo inventory (roles, plans, naming SSOT)

---

## Executive summary

| Area | Verdict |
|------|---------|
| **Layer model** (runtime → gateway → observability → publication) | **Aligned** — intake matches active plans and shipped `k3s_*` roles |
| **`ai_*` role names** | **Naming drift only** — implement as **extend `k3s_*` / `llm_compute_windows` / `ipam_netbox`**, not new `ai_*` directories unless a deliberate rename pass is approved |
| **5090 GPU lane** | **Repo-ready** for Langfuse, LiteLLM, Jupyter, fuzlang stack, Windows GPU driver validate |
| **vLLM / HF cache / Ollama** | **Blocked or needs gap** — roles and playbooks from vLLM plan not on disk |
| **Second / third GPU lanes** | **Reconciling** — see [host-role-reconciliation-discussion.md](./host-role-reconciliation-discussion.md): **hvh-01** = second GPU/storage; **dev-workstation-win** = third (design-only) |
| **Product vocabulary** (RIPI, HD-01, HWC-01) | **Intake-only** until schema/product decisions |
| **Phase 0R reconciliation** | **In progress** — placeholder→implementation docs; Phase 2 **blocked** until host placement + vLLM strategy confirmed |
| **Phase 2** | Infra incomplete plan **after 0R**; not unblocked for live NetBox seeds until stable URLs |

---

## 0.1 — Terminology and architecture labels

### Adopt in repo docs (see [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md))

| Term | Repo target |
|------|-------------|
| AI **product engineering** lab (not ML-training-first) | `README.md`, estate diagram intro |
| Distributed capability lanes (`hyperv_lane_gpu`, `hyperv_lane_storage`) | Already in SSOT; cite in layer-model doc |
| Runtime / gateway / observability / publication / catalog | New layer-model reference |
| GPU lane jobs (5090 primary; second GPU assigned role) | Estate diagram + layer-model |
| mac-dev = operator / IDE / controller | `connection-surfaces.md` |
| Model **lanes** (LiteLLM aliases) vs **catalog** (future) | Layer-model + LiteLLM plan |

### Conflicts — repo wins

| Intake | Repo truth |
|--------|------------|
| Server-225, network-server | `hom-lab-ctl-hvh-02` (GPU), `hom-lab-ctl-hvh-01` (storage) — `AGENTS.md` #14, `live-object-registry.yml` |
| `ai_*` Ansible roles | `k3s_litellm_gateway`, `k3s_langfuse_platform`, `dev_jupyterlab_workbench`, etc. |
| `ai_langfuse_platform` | Duplicate of `k3s_langfuse_platform` |
| `litellm_gateway` (old plan name) | `k3s_litellm_gateway` (shipped) |
| Strong “5090 Docker-first; K3s secondary” | Active AI services on **k3s-02** today |
| Third GPU as active experimental lane | `dev-3090-win` **deferred** — `edge-dev-host-naming-netbox-incomplete` |
| Enterprise multi-agent platform | Out of scope (Group A + framework default) |

### Intake-only until decision

| Label | Action |
|-------|--------|
| **HD-01**, **HWC-01** | Product governance labels — not hostname/role codes |
| **RIPI**, `ripi-private`, `ai_ripi_dashboard` | Product / future-state |
| **`node_classes`** (`ai_gpu_primary`, …) | Map to inventory groups in reference doc; do not bulk-assign in host_vars yet |
| **OpenClaw** | Stated in intake; no Ansible role |
| **`ipam_netbox_ai_services` as separate role** | Extend `roles/ipam_netbox/` instead |

---

## 0.2 — Doc updates

| Priority | File | Status |
|----------|------|--------|
| P0 | [ASSESSMENT.md](./ASSESSMENT.md) | **done** (this file) |
| P0 | [docs/reference/ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) | **done** (Phase 0.6) |
| P0 | [README.md](../../../README.md) | **done** (lab identity + compact host names in nodes section) |
| P1 | [docs/reference/naming-standards/README.md](../../reference/naming-standards/README.md) | **done** (link to layer-model) |
| P1 | [source-reconciliation.yml](../../reference/naming-standards/source-reconciliation.yml) | **done** (intake capture entry) |
| P1 | [phase-1-TRIAGE.md](./phase-1-TRIAGE.md) | **done** (routes confirmed post-0.5) |
| P2 | Estate diagram `cst-hom-lab-ctl-dia-homelab-estate-04.md` | Pending — GPU lane jobs paragraph |
| P2 | `connection-surfaces.md` | Pending — operator surface note |
| P2 | Align `docs/plans/2026-05-19--litellm-gateway/README.md` to `k3s_litellm_gateway` | Pending |

---

## 0.3 — Ansible structure gaps

### Implemented (use these — do not recreate as `ai_*`)

| Path | Purpose |
|------|---------|
| `roles/k3s_litellm_gateway/` | LiteLLM on K3s |
| `roles/k3s_langfuse_platform/` | Langfuse on K3s |
| `roles/k3s_traefik_routes/` | Ingress |
| `roles/dev_jupyterlab_workbench/` | Jupyter + cookbooks |
| `roles/langfuse_cli/` | macOS CLI |
| `roles/llm_compute_windows/` | NVIDIA driver on Windows GPU hosts |
| `roles/common/gpu_driver_validation/` | `nvidia-smi` verify |
| `roles/stacks_fuzlang_net/` | Postgres / support on dkr-02 |
| `roles/ipam_netbox/` | NetBox seed (incl. langfuse, litellm, jupyter services) |
| `roles/mcp_servers/huggingface/` | IDE MCP only — **not** HF cache on GPU nodes |

### Missing vs intake (net-new or from deferred plans)

| Intake role | Repo action |
|-------------|-------------|
| `ai_vllm_runtime` | Implement per `docs/plans/2026-05-19--vllm-runtime-and-huggingface-cache/` — name likely `k3s_vllm_runtime` or `vllm_runtime`, not `ai_*` |
| `ai_huggingface_client` | Net-new HF token + cache paths |
| `ai_nvidia_runtime` | Extend `llm_compute_windows` + `validate_windows_gpu_hosts.yaml` |
| `ai_ollama_runtime` | Net-new (`dev_3090` flags only today) |
| `ai_ide_client` | Extend `deploy_development_nodes.yaml`, `k3s_mac_client` |
| `ai_privacy_policy`, `ai_ripi_dashboard` | Future-state |
| `ipam_netbox_ai_services` | Extend `ipam_netbox` defaults when URLs stable |

### Playbook extension points

| Playbook | Extend for |
|----------|------------|
| `deploy_litellm_gateway.yaml` | Alias contract, routing |
| `deploy_langfuse_platform.yaml` | Trace metadata vars |
| `deploy_jupyterlab_workbench.yaml` | Cookbook paths |
| `deploy_development_nodes.yaml` | IDE / OpenClaw when defined |
| `deploy_ipam_netbox.yaml` | New AI service slugs after publication |
| `k3s_bootstrap_k3s02.yaml` | GPU operator / worker (vLLM plan) |
| `llm_compute_windows.yaml` | Per-lane GPU policy |

### Name map (intake → repo) — use in Phase 2 plans

| Intake | Repo (today) |
|--------|----------------|
| `ai_litellm_gateway` | `k3s_litellm_gateway` |
| `ai_langfuse_platform` | `k3s_langfuse_platform` |
| `ai_ide_client` | `langfuse_cli`, `k3s_mac_client`, `deploy_development_nodes` |
| Jupyter (intake) | `dev_jupyterlab_workbench` |

---

## 0.4 — NetBox / inventory gaps

### Integrated today

- Hosts: `hom-lab-ctl-hvh-02`, `hom-lab-ctl-dkr-02`, `hom-lab-ctl-k3s-02` (`hyperv_lane_gpu`)
- Service codes: `llm`, `lfs`, `jpy`, `vlm` (code only for vLLM), `hfc` (code only)
- NetBox L1 seeds: `langfuse-k3s-web`, `litellm-k3s-gateway`, `jupyterlab-workbench` (+ dkr support stack)
- Ingress: `langfuse.hom.lab`, `litellm.hom.lab` in registry

### Gaps

| Gap | Blocker |
|-----|---------|
| Second GPU host (`second-gpu-host`) | No `inventory_hostname` — map to physical host |
| Third GPU (`third-gpu-desktop`) | Likely `dev-3090-win` or `dev-workstation-win` — **user decision** |
| vLLM NetBox services (`vllm-primary-5090`, …) | No runtime URL — publication plan at 0% |
| Ollama / RIPI / OpenClaw services | No roles; no stable endpoints |
| Intake L1 slug drift (`litellm-gateway` vs `litellm-k3s-gateway`) | Reconcile in plan, not silent rename |
| `node_classes` on hosts | Not in inventory SSOT |
| Edge fleet NetBox | `edge-dev-host-naming-netbox-incomplete` |

### Placement crosswalk (intake → repo)

```text
5090 primary lane     → hom-lab-ctl-hvh-02 + dkr-02 + k3s-02  (integrated)
Second GPU reviewer   → (unmapped)
Third GPU experimental→ dev-3090-win OR dev-workstation-win (deferred)
Mac operator          → mac-dev (not in NetBox)
Langfuse/LiteLLM/Jupyter → k3s-02 (integrated)
Storage/obs lane      → hom-lab-ctl-hvh-01 (not intake “network server” prose)
```

---

## 0.5 — Buildability (confirms triage routes)

| ID | Topic | Buildability | Confirmed route |
|----|-------|--------------|-----------------|
| B-01 | Multi-GPU lanes | **blocked** | incomplete |
| B-02 | HF client/cache | **needs gap** | incomplete |
| B-03 | NVIDIA runtime verify | **needs gap** | incomplete |
| B-04 | vLLM primary | **blocked** | incomplete — extend `k3s-vllm-service-publication-incomplete` |
| B-05 | vLLM secondary | **blocked** | incomplete |
| B-06 | Ollama | **needs gap** | incomplete |
| B-07 | LiteLLM aliases | **needs gap** | incomplete |
| B-08 | Langfuse trace metadata | **needs gap** | extract + incomplete |
| B-09 | IDE client | **needs gap** | incomplete |
| B-10 | Privacy policy | **blocked** | future-state |
| B-11 | RIPI dashboard | **blocked** | future-state |
| B-12 | NetBox AI services seed | **needs gap** | incomplete — extend `ipam_netbox` |
| B-13 | Node classes | **repo-ready** (extract) | extract |
| B-14 | Impl order 1–10 | **blocked** | incomplete |
| A-01 | Lab identity | **repo-ready** (extract) | extract → docs |
| A-02 | Eval dashboard | **blocked** | future-state |
| A-03 | Eval engineering | **blocked** | future-state |
| A-04 | HD-01 | **repo-ready** (extract) | extract |
| A-05 | HWC-01 | **repo-ready** (extract) | extract |
| A-06 | RAG / memory | **blocked** | future-state |
| A-07 | Enterprise orchestration | **defer** | defer |
| A-08 | Fine-tuning | **blocked** | future-state |

**Repo-ready for live apply today (with verification):** Langfuse, LiteLLM, Jupyter on k3s-02; fuzlang Postgres; Windows GPU driver install/validate on commissioned Windows GPU hosts; existing NetBox seeds for K3s services.

---

## 0.6 — Safe updates applied

| Change | Path |
|--------|------|
| Phase 0 exit artifact | This file |
| Layer model reference | `docs/reference/ai-homelab-layer-model.md` |
| Naming README link | `docs/reference/naming-standards/README.md` |
| Intake reconciliation row | `docs/reference/naming-standards/source-reconciliation.yml` |
| Project README lab identity | `README.md` (nodes section) |
| Triage routes confirmed | `phase-1-TRIAGE.md` |

**Deferred (needs host/URL decision or plan):** `ipam_netbox/defaults` new seeds, `live-object-registry` vLLM stubs, inventory `node_classes`, new Ansible roles.

---

## Decisions required before Phase 2

1. **Second GPU** — which physical host / inventory key is `ai_gpu_secondary`?
2. **Third GPU** — `dev-3090-win` vs `dev-workstation-win` vs other?
3. **vLLM placement** — K3s on k3s-02 vs Windows-native on hvh-02 (plans favor K3s + 5090)?
4. **Service L1 slugs** — intake names (`vllm-primary-5090`) vs repo pattern (`*-k3s-*`)?
5. **`ai_*` vs `k3s_*`** — document alias only (recommended) or rename roles?

---

## Phase 2 recommended order

1. `docs/plans/YYYY-MM-DD--ai-homelab-gpu-litellm-ansible-incomplete/` — infra packet (B-01–B-14), **no `ai_*` role creation without naming decision**
2. Extend `docs/plans/2026-05-28--k3s-vllm-service-publication-incomplete/` after runtime exists
3. Resolve `edge-dev-host-naming-netbox-incomplete` in parallel if second/third GPU in scope
4. `docs/plans/YYYY-MM-DD--ai-product-engineering-lab-future-state/` — Group A (no execute)

---

## Agent reports (Phase 0 parallel inventory)

| Agent focus | Agent ID | Key finding |
|-------------|----------|-------------|
| Ansible / roles / plans | f7405d0b-2bb7-41c0-9830-7de0ea0cad40 | Zero `ai_*` roles; `k3s_*` shipped; vLLM plan roles missing |
| NetBox / naming SSOT | bfbc153e-77ae-41bd-ab88-615117e7451f | 5090 lane integrated; multi-GPU blocked; HD-01/HWC-01 net-new |
| Terminology / docs | d0c52f8e-3337-47b1-a191-211f9eb22628 | Layer model aligned; README legacy names conflict |

---

Sources checked:
- `docs/intake/netbox/netbox_ai_infra_impl_planning_wip/` syntheses and triage
- `roles/`, `playbooks/`, `inventory/`, `docs/plans/`, `docs/reference/naming-standards/`
- `AGENTS.md`, `README.md`, estate diagram, active plan READMEs
