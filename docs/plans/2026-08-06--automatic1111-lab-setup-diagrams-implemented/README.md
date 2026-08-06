---
name: Automatic1111 lab setup diagrams
overview: >-
  Doc-only packet: promote Automatic1111 lab architecture into its own plan
  folder and add studio-wide setup plus resource/dependency diagrams using
  generic role language from the creative-studio brainstorm.
lifecycle: implemented
implemented_date: "2026-08-06"
archive_candidate: false
github_issue: 15
scope: doc-only
netbox_scope: false
depends_on_plans: []
unblocks: []
todos:
  - id: promote-lab-arch
    content: Promote automatic1111-lab-architecture pack into this plan diagrams/
    status: completed
  - id: studio-setup-diagram
    content: Pack SVG for whole studio setup with A1111 as Phase A still backend
    status: completed
  - id: resources-deps-diagram
    content: Pack SVG for generic resource kinds and A1111 dependencies
    status: completed
  - id: plan-gate
    content: Architecture / Capability Routing / Naming + Diagram Inventory in README
    status: completed
  - id: redirect-brainstorm
    content: Point brainstorming_designs/comfyui_automatic1111 at this plan
    status: completed
isProject: false
---

# Automatic1111 lab setup diagrams

## Summary

Doc-only packet that owns **Automatic1111** architecture diagrams for this lab.
Split from the combined brainstorm folder
`docs/brainstorming_designs/comfyui_automatic1111`. Companion ComfyUI packet:
[`../2026-08-06--comfyui-lab-setup-diagrams-implemented/`](../2026-08-06--comfyui-lab-setup-diagrams-implemented/).

Creative-studio brainstorm source:
[`docs/brainstorming_designs/date_tbd--glam-draft1/`](../../brainstorming_designs/date_tbd--glam-draft1/).
This plan describes those pieces by **what they represent**, not by content theme.

## Capability Packet Boundary

| Field | Value |
| --- | --- |
| Capability identifier | `automatic1111-lab-setup-diagrams` |
| Owner manifest | This plan folder `README.md` + `diagrams/README.md` |
| Owned files | `docs/plans/2026-08-06--automatic1111-lab-setup-diagrams-implemented/**` |
| Integration anchors | Links from brainstorm README; optional later link from `docs/reference/local-ai-chat-and-image-stack.md` |
| Update behavior | Re-render Mingrammer scripts via `create-diagrams` docker helper |
| Removal behavior | Delete this plan folder; restore brainstorm pointers if needed |

## Scope (in)

- Automatic1111 host / Open WebUI Images / direct UI architecture
- Studio-wide surfaces where A1111 is the Phase A still pixel backend
- Generic meanings of studio resource kinds that feed A1111 stills

## Scope (out)

- No inventory / playbook / runtime mutations (doc-only)
- ComfyUI pack ownership (sibling plan)
- Workflow graph authorship (ComfyUI-owned)
- Content-specific prompt wording

## What each studio piece represents (generic)

| Piece (brainstorm) | Generic meaning |
| --- | --- |
| Studio profile (`config.yaml`) | Shared map of hosts, pipelines, and alias → asset paths |
| Coaching prompts | Chat system instructions that coach still-prompt writing |
| Still style presets | Reusable positive prompt templates for the still pipeline |
| Negative presets | Shared “avoid this” cue lists for stills |
| Smoke examples | Paste-ready prompts for a first successful still |
| Lab share | Deployed working set: inputs, outputs, copied presets |
| Still pipeline | Portrait / reference → polished still (Phase A home) |
| Chat gateway (LiteLLM) | Prompt coaching only — pixels go to A1111 `sdapi` |
| Chat UI (Open WebUI) | Operator chat + Images button |
| Desktop chat runtime | Ollama backends used for coaching |
| Model files on host | SD-class checkpoints + ControlNet packs |
| Phase A | Bootstrap stills on the smaller CUDA host via A1111 |
| Phase B (sibling) | Advanced stills / motion on ComfyUI — not this packet’s runtime |

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | Author/render pack SVGs under `diagrams/`; keep inventories current |
| **Verify** | Every stem has `.py` + `.svg`; Diagram Inventory lists `pack-svg` |
| **Undo** | Delete this plan folder (no runtime change) |
| **Change class** | Doc-only / brainstorm plan packet |

## Checklist

- [x] Plan packet created (`scope: doc-only`)
- [x] Promoted `automatic1111-lab-architecture.*`
- [x] `diagrams/automatic1111-studio-setup.*`
- [x] `diagrams/automatic1111-resources-dependencies.*`
- [x] Architecture / Capability Routing / Naming sections present
- [x] `diagrams/README.md` index
- [x] Brainstorm folder redirects here

## Architecture/Structure Diagram

Primary pack: [diagrams/automatic1111-studio-setup.svg](diagrams/automatic1111-studio-setup.svg)

```mermaid
flowchart TB
  op[Operator]
  chat[Chat UI + LiteLLM + desktop Ollama]
  images[Open WebUI Images]
  a1111[Automatic1111 still backend]
  direct[Direct A1111 Web UI]
  share[Lab share working set]
  models[Host checkpoints]

  op --> chat
  op --> images --> a1111
  op --> direct --> a1111
  a1111 --> models
  a1111 --> share
```

## Capability Routing Diagram

```mermaid
flowchart LR
  stillIn[Still / reference input]
  coach[Still coaching chat]
  images[Open WebUI Images]
  direct[A1111 Web UI]
  api[sdapi txt2img / img2img]
  out[Outputs on lab share]

  stillIn --> coach
  coach --> images
  stillIn --> images
  stillIn --> direct
  images --> api
  direct --> api
  api --> out
```

## Naming/Modeling Diagram

```mermaid
flowchart TB
  profile[Studio profile]
  alias[Chat alias name]
  coachAsset[Coaching asset path]
  presetDir[Still preset directory]
  baseUrl[A1111 base URL]
  webuiEnv[Open WebUI Images env]

  profile --> alias
  alias --> coachAsset
  profile --> presetDir
  profile --> baseUrl
  baseUrl --> webuiEnv
```

## Diagram Inventory

| Diagram | Medium | Path |
| --- | --- | --- |
| Lab host architecture | pack-svg | [diagrams/automatic1111-lab-architecture.svg](diagrams/automatic1111-lab-architecture.svg) |
| Studio setup (roles) | pack-svg | [diagrams/automatic1111-studio-setup.svg](diagrams/automatic1111-studio-setup.svg) |
| Resources / dependencies | pack-svg | [diagrams/automatic1111-resources-dependencies.svg](diagrams/automatic1111-resources-dependencies.svg) |
| Architecture sketch | mermaid-fence | this README |
| Capability routing | mermaid-fence | this README |
| Naming / modeling | mermaid-fence | this README |

## Diagram gate receipt

| Gate | Status |
| --- | --- |
| Architecture/Structure present | pass — pack SVG + Mermaid |
| Capability Routing present | pass — Mermaid |
| Naming/Modeling present | pass — Mermaid (alias / asset / URL map) |
| Diagram Inventory final | pass |
| Medium declared | pack-svg + mermaid-fence |

## Assumptions / defaults

- A1111 remains the Open WebUI Images backend for Phase A stills.
- Pixels do not route through LiteLLM today.
- Creative-studio brainstorm remains the seed for asset trees; this packet only
  documents structure.

## Plan verification receipt

**Slice:** doc-only v1  
**Verified at:** 2026-08-06  
**Verifier:** agent run

### Obligation inventory

| ID | Source | Obligation | In slice scope? | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| O-01 | Checklist | Plan packet created (`scope: doc-only`) | yes | pass | This README frontmatter `scope: doc-only` |
| O-02 | Checklist | Promote `automatic1111-lab-architecture.*` | yes | pass | `diagrams/automatic1111-lab-architecture.{py,svg,png}` present |
| O-03 | Checklist | Studio setup pack SVG | yes | pass | `diagrams/automatic1111-studio-setup.{py,svg,png}` present |
| O-04 | Checklist | Resources/dependencies pack SVG | yes | pass | `diagrams/automatic1111-resources-dependencies.{py,svg,png}` present |
| O-05 | Checklist | Architecture / Capability Routing / Naming sections | yes | pass | Sections present in this README |
| O-06 | Checklist | `diagrams/README.md` index | yes | pass | File lists three stems |
| O-07 | Checklist | Brainstorm folder redirects here | yes | pass | `docs/brainstorming_designs/comfyui_automatic1111/README.md` |
| O-08 | Apply | Author/render pack SVGs under `diagrams/` | yes | pass | Docker render receipt for new stems; promoted lab stem copied |
| O-09 | Verify | Every stem has `.py` + `.svg`; inventory lists `pack-svg` | yes | pass | Shell verify `ALL_VERIFY_PASS` for three stems; Diagram Inventory |
| O-10 | Undo | Documented as delete plan folder | yes | pass | Change-class table Undo row |
| O-11 | Class | Doc-only / no runtime mutation | yes | pass | `scope: doc-only`; `netbox_scope: false` |
| O-12 | Diagram gate | Architecture + Routing + Naming + Inventory | yes | pass | `## Diagram gate receipt` all pass |
| O-13 | Frontmatter | `depends_on_plans` / `unblocks` empty | yes | pass | `[]` / `[]` |
| O-14 | Capability boundary | Owner / owned files / removal documented | yes | pass | `## Capability Packet Boundary` |
| O-15 | Follow-on | Optional link from local-ai-chat stack doc | no | deferred | Optional integration anchor; not required for slice |

### Summary

- In-scope obligations: 14 — pass: 14, fail: 0, blocked: 0, pending: 0
- Deferred (explicit out-of-slice): 1

### Completion gate (all required for `lifecycle: implemented`)

- [x] Every **in-scope** obligation is `pass` or `n/a` with reason
- [x] Diagram gate receipt present and passing
- [x] No unresolved On Deck rows (none open)

## Sources checked

- `docs/brainstorming_designs/comfyui_automatic1111/`
- `docs/brainstorming_designs/date_tbd--glam-draft1/design.md`
- `docs/brainstorming_designs/date_tbd--glam-draft1/assets/config.yaml`
- `docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/README.md` (packet shape)
- `docs/codex_framework/architecture-diagram-routing.md`
- `docs/reference/local-ai-chat-and-image-stack.md`
