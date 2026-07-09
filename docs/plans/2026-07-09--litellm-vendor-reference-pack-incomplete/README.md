---
lifecycle: in_progress
scope: implementation
netbox_scope: false
depends_on_plans:
  - 2026-07-08--ai-library-entry-capability-incomplete
unblocks: []
---

# LiteLLM Vendor Reference Pack

## Summary

Govern a new LiteLLM vendor entry under `ai-resource-library/vendors/litellm`. Production
homelab gateway traffic remains on `k3s_litellm_gateway` at `http://litellm.hom.lab/v1`.

This slice captures:

- LiteLLM proxy quick start, admin UI, routing, model access, CLI, supported endpoints
- authentication, caching, memory, skills gateway, and AI-tool integration tutorials
- integrations overview plus summary captures for nested integration pages
- OpenAPI/Swagger export from `https://litellm-api.up.railway.app/openapi.json`
- Context7 notes for `/websites/litellm_ai` and `/berriai/litellm`

No standalone Mac or dev-host `litellm[proxy]` pipx role — gateway is K3s-only in this repo.

## Capability Packet Boundary

| Field | Value |
|-------|-------|
| Capability identifier | `litellm_vendor_reference_pack` |
| Owner manifest | This packet + `entry-spec.yml` |
| Owned files | `docs/plans/2026-07-09--litellm-vendor-reference-pack-incomplete/**`; `ai-resource-library/vendors/litellm/**`; `ai-resource-library/sdk-context/context7/litellm/**`; `ai-resource-library/scripts/ai-library-entry/litellm/**` |
| Integration anchors | Firecrawl via repo MCP client, Context7 `/websites/litellm_ai`, homelab `k3s_litellm_gateway` defaults |
| Update behavior | Re-run `build_litellm_vendor_pack.mjs` to refresh docs, swagger, indexes, and metadata |
| Removal behavior | Delete vendor subtree and sdk-context notes; remove vendors README row |

## Apply / Verify / Undo / Change class

- **Apply:** run build script for library pack
- **Verify:** `ruby validate_entry_spec.rb entry-spec.yml`; pack files exist; homelab gateway curls documented against `k3s_litellm_gateway` routes
- **Undo:** delete generated vendor pack if retiring slice
- **Class:** bootstrap/semi-manual for first swagger fetch; vendor pack is refreshable content

## Architecture/Structure Diagram

```mermaid
graph TB
  subgraph dotfile_vnext [dotfile-vnext]
    plan[docs/plans/2026-07-09--litellm-vendor-reference-pack-incomplete]
    entrySpec[entry-spec.yml]
    k3sRole[roles/k3s_litellm_gateway]
  end

  subgraph ai_lib [ai-resource-library]
    vendor[vendors/litellm]
    sdk[sdk-context/context7/litellm]
    script[scripts/ai-library-entry/litellm/build_litellm_vendor_pack.mjs]
    openapi[vendors/litellm/openapi]
  end

  subgraph external [External]
    docs[docs.litellm.ai]
    swagger[litellm-api.up.railway.app/openapi.json]
    fc[Firecrawl MCP]
    c7[Context7 MCP]
    homelab[litellm.hom.lab K3s gateway]
  end

  plan --> entrySpec
  script --> fc
  script --> c7
  script --> vendor
  script --> sdk
  script --> openapi
  docs --> fc
  swagger --> script
  k3sRole --> homelab
  vendor --> homelab
```

## Capability Routing Diagram

```mermaid
graph TB
  request[Operator request]
  request --> k3s[k3s_litellm_gateway on K3s]
  k3s --> ui[http://litellm.hom.lab/ui]
  k3s --> models[GET /v1/models with master key]
```

## Naming/Modeling Diagram

```mermaid
graph LR
  lane[model_lane code-deep] --> alias[LiteLLM model_name]
  alias --> backend[vLLM hosted_vllm route]
  service[litellm.hom.lab] --> traefik[Traefik ingress]
  traefik --> nodeport[NodePort 30400 supplemental]
```

## Checklist

- [x] Governed packet + `entry-spec.yml`
- [x] Vendor pack build script and outputs
- [x] Swagger/OpenAPI index materialized
- [x] Entry-spec validator pass
- [x] Homelab operator curl/UI reference in vendor pack

## On Deck — user decisions to integrate

- **2026-07-09:** Reject standalone `litellm_proxy` Mac/dev pipx role. K3s gateway only.

## Diagram gate receipt

- [x] Architecture/Structure
- [x] Capability Routing
- [x] Naming/Modeling
- [x] Diagram Inventory lists required sections

## Diagram Inventory

### Diagrams Included

- Architecture/Structure Diagram
- Capability Routing Diagram
- Naming/Modeling Diagram

### Additional Diagrams Available On Request

- Model lane routing sequence
- OpenAPI tag map visualization
