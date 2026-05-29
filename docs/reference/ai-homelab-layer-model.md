# AI homelab layer model

Canonical vocabulary for how this repo describes the homelab AI stack. Intake
provenance: `docs/intake/netbox/netbox_ai_infra_impl_planning_wip/` (Phase 0).
Enforcement: active plans and shipped Ansible roles — not chat export names alone.

## Lab identity

This homelab is an **AI product engineering** environment: agents, evaluation,
observability, and controlled model lanes for building software — not a
foundation-model training farm. Work runs **local-first on the operator Mac**
with **cluster-backed** shared services (LiteLLM, Langfuse, Jupyter) on the GPU
lane K3s guest.

## Capability lanes

| Lane | Inventory anchor | Primary jobs |
|------|------------------|--------------|
| **GPU / inference** | `hyperv_lane_gpu` — `hom-lab-ctl-hvh-02`, `hom-lab-ctl-dkr-02`, `hom-lab-ctl-k3s-02` | vLLM (planned), LiteLLM, Langfuse, Jupyter, GPU verify |
| **Storage / observability** | `hyperv_lane_storage` — `hom-lab-ctl-hvh-01`, dkr-01, k3s-01 | NetBox, Loki, Grafana, long-retention stack |
| **Operator** | `mac-dev` (`execution_nodes`) | Ansible controller, IDE, CLI — not an inference host |

Retired names (`Server-225`, `network-server`) must not appear in new docs;
use compact schema hostnames per `live-object-registry.yml`.

## Layers (bottom to top)

```text
┌─────────────────────────────────────────────────────────────┐
│ Catalog (future) — durable model inventory, not vLLM rows   │
├─────────────────────────────────────────────────────────────┤
│ Publication — hom.lab + hosts-file + NetBox when URL stable │
├─────────────────────────────────────────────────────────────┤
│ Observability — Langfuse (lfs), traces, eval metadata       │
├─────────────────────────────────────────────────────────────┤
│ Gateway — LiteLLM (llm), model lanes / aliases              │
├─────────────────────────────────────────────────────────────┤
│ Runtime — vLLM (vlm), Ollama (candidate), GPU verify        │
├─────────────────────────────────────────────────────────────┤
│ Substrate — Hyper-V, dkr, k3s, Windows GPU drivers, HF cache│
└─────────────────────────────────────────────────────────────┘
```

| Layer | Service code | Shipped role (repo) | Notes |
|-------|--------------|---------------------|-------|
| Runtime | `vlm` | *(planned)* `vllm_runtime` / `k3s_vllm_runtime` per plan | Not deployed; see `2026-05-28--k3s-vllm-service-publication-incomplete` |
| Gateway | `llm` | `k3s_litellm_gateway` | Model **lanes** = LiteLLM `model_name` aliases (`code-deep`, …) — schema pattern **candidate**; see [gpu-lane-and-model-lane-mapping-evaluation.md](../intake/netbox/netbox_ai_infra_impl_planning_wip/gpu-lane-and-model-lane-mapping-evaluation.md) |
| Observability | `lfs` | `k3s_langfuse_platform` | Trace metadata contract: intake `1.4.0` |
| Publication | — | `homelab_hosts_file`, `ipam_netbox`, Traefik routes | Deferred until stable runtime URL |
| Catalog | — | — | Reserved; do not confuse with NetBox **service** rows |

## GPU lane policy

- **RTX 5090 (primary):** deep / private primary vLLM lane when runtime lands.
- **Second GPU:** assigned purpose (reviewer, embeddings) — not an equal peer;
  host identity must be chosen in inventory before NetBox seed.
- **Edge desktops** (`dev-3090-win`, `dev-workstation-win`): deferred; see
  `edge-dev-host-naming-netbox-incomplete`.

## Intake name map (do not implement `ai_*` blindly)

| Intake label | Repo role / surface |
|--------------|---------------------|
| `ai_litellm_gateway` | `k3s_litellm_gateway` |
| `ai_langfuse_platform` | `k3s_langfuse_platform` |
| `ai_vllm_runtime` | Planned vLLM role (see vLLM plan packet) |
| `ai_ide_client` | `langfuse_cli`, `k3s_mac_client`, `deploy_development_nodes` |

Full assessment: [ASSESSMENT.md](../intake/netbox/netbox_ai_infra_impl_planning_wip/ASSESSMENT.md).

**Operator guides:** [vllm-architecture-discussion.md](../intake/netbox/netbox_ai_infra_impl_planning_wip/vllm-architecture-discussion.md) (what vLLM is, where to install), [reconciliation-workflow-discussion.md](../intake/netbox/netbox_ai_infra_impl_planning_wip/reconciliation-workflow-discussion.md).

## Product vs infra boundary

- **Infra:** lanes, roles, NetBox services, Traefik, connection surfaces, naming schema.
- **Hybrid:** LiteLLM aliases, Langfuse trace fields, privacy routing (config owned by infra roles).
- **Product (future-state):** RIPI dashboard, HD-01/HWC-01 domains, eval UX, heavy RAG — not hostname codes.

## Related SSOT

- [naming-standards/README.md](./naming-standards/README.md)
- [naming-standards/live-object-registry.yml](./naming-standards/live-object-registry.yml)
- [connection-surfaces.md](./connection-surfaces.md)
- [diagram: homelab estate](../diagrams/cst-hom-lab-ctl-dia-homelab-estate-04.md)
