---
title: AFT Terraform Upgrade Prep Pages
lifecycle: incomplete-wip
scope: doc-only
date: 2026-07-13
capability: aft-terraform-upgrade-prep-pages
---

# AFT Terraform Upgrade Prep Pages

## Summary

Promote Terraform-binary upgrade execution and pre-change research methodology from `oneoffs/issue/aft_version_upgrade_report` into two operational library pages, refresh aws-aft Context7/indexes, and lightly archive referenced oneoffs sources plus copies of produced pages.

## Capability Packet Boundary

- **Capability:** `aft-terraform-upgrade-prep-pages`
- **Owned files:**
  - `ai-resource-library/vendors/aws/control_tower_operational/aft-terraform-binary-upgrade-runbook.md`
  - `ai-resource-library/vendors/aws/control_tower_operational/aft-upgrade-prep-research-and-compatibility.md`
  - wip stubs, operational/combined/indexes/context7 updates
  - `oneoffs/.../archive/2026-07-13--library-extract/` + oneoffs copies of produced pages
  - this packet + `entry-spec.yml`
- **Integration anchors:** `page-index.json`, `indexes/aws-aft/`, `sdk-context/context7/aws-aft/`
- **Update behavior:** edit library SSOT pages in place; refresh oneoffs copies when needed
- **Removal behavior:** remove index/crosswalk rows in the same change

## Apply / Verify / Undo / Change class

- **Apply:** write two library pages; stub wip pages; retarget indexes; refresh Context7 links; archive referenced oneoffs sources; copy produced pages
- **Verify:** Came-from + binary≠module cross-links; indexes list new pages; oneoffs archive + copies present
- **Undo:** git revert
- **Change class:** idempotent documentation + library indexing (repo-only)

## Architecture/Structure Diagram

```mermaid
graph TB
  subgraph oneoffs [oneoffs aft_version_upgrade_report]
    Src[Referenced sources]
    Arch[archive/2026-07-13--library-extract]
    Copies[copies of P1 P2]
  end
  subgraph library [ai-resource-library]
    P1[aft-terraform-binary-upgrade-runbook]
    P2[aft-upgrade-prep-research-and-compatibility]
    Mod[aft-platform-module-upgrade]
    Can[aft-upgrade-tools-canonical-values]
    C7[sdk-context/context7/aws-aft]
    Idx[indexes/aws-aft]
  end
  Src -->|"move"| Arch
  Src --> P1
  Src --> P2
  P1 -->|"copy"| Copies
  P2 -->|"copy"| Copies
  P1 --> Mod
  P1 --> Can
  P2 --> Can
  P1 --> C7
  P2 --> C7
  C7 --> Idx
```

## Capability Routing Diagram

```mermaid
graph LR
  Prep[Prep research page] -->|"blockers cleared"| Binary[Binary SSM runbook]
  Prep -->|"module ref"| Module[Platform module runbook]
  Binary --> Invoke[Customizations invoke]
```

## Naming/Modeling Diagram

N/A — no NetBox/inventory naming changes; page filenames follow existing `aft-*-*.md` operational pack pattern.

## Diagram gate receipt

- [x] Architecture/Structure: repo paths, oneoffs archive, library SSOT, indexes
- [x] Capability Routing: prep → binary vs module
- [x] Naming/Modeling: N/A — docs-only filenames, no NetBox/schema change
- [x] Diagram Inventory lists required sections

## Diagram Inventory

### Diagrams Included
- **Architecture/Structure Diagram**
- **Capability Routing Diagram**
- **Naming/Modeling:** N/A with reason above

### Additional Diagrams Available On Request
- Deployment Flow: sandbox → SSM put → pipeline smoke
- Integration Sequence: validation phases static → schema → runtime

## On Deck — user decisions to integrate

- oneoffs: archive referenced sources only; copy produced pages; no broad cleanup — **integrated**
