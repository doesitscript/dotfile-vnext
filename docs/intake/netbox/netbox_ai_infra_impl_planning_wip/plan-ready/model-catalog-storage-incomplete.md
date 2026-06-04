# Plan-ready — Model catalog on storage lane (HF weights)

**Status:** awaiting operator review  
**Depends on:** D-4 operator confirm of share path on `hom-lab-ctl-hvh-01`

---

## Scope

**Catalog layer** only — not vLLM or LiteLLM.

| Field | Candidate value |
|-------|-----------------|
| Canonical path | `\\hom-lab-ctl-hvh-01\public\models\huggingface\` |
| Manifest SSOT | `inventory/group_vars/model_catalog/manifest.yml` (proposed) |
| Registry | `live-object-registry.yml` rows per HF repo |

vLLM on k3s-02 **reads** from share or local PVC — does not replace catalog.

---

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | Share layout + manifest YAML; optional download automation later |
| **Verify** | Path reachable from k3s-02 worker; manifest carries the full model-purpose candidate set and no row stronger than `candidate` without research/probe evidence |
| **Undo** | Remove manifest file |
| **Class** | Idempotent config + bootstrap download |

---

## Obligations (preview)

| ID | Obligation |
|----|------------|
| C-01 | D-4 path confirmed |
| C-02 | Manifest pattern in naming schema |
| C-03 | Catalog rows cover `code-deep`, `code-fast`, `code-review`, `code-test`, `ripi-private`, `embeddings-local`, `experiment`, and cloud/public fallback routing note |
| C-04 | vLLM plan references catalog row(s) without shrinking catalog to one primary model |

---

## On Deck — user decisions to integrate

| ID | User decision / direction | Target integration | Status |
|----|---------------------------|--------------------|--------|
| OD-AI-001 | Implement several model lanes now | Full catalog candidate set | integrated into stub; governed plan carries receipt rows |
