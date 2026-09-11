# 06 — Expert on-call (lab consultation)

After the heavy Expert ↔ Researcher pass and the refined technical handoff exist,
the On-site Expert stays available as a **lean on-call** for Implementer /
Evaluator questions—same role a human would get in this recreatable lab.

## When to summon

- Named technical fork (placement, sizing, mechanism, Ansible ownership fit)
- Clarification of a settled hard correction or functional-area target
- Best recommendation when research already covers the surface

Do **not** summon for: broad rediscovery, Apply authority, Evaluator verdicts,
or “validation questions instead of a recommendation.”

## Lab posture (cattle)

This homelab is recreatable. Expert answers with an evidence-backed **Best
recommendation** (or Preference with stated assumptions). Do not invent
production gates as blockers:

- no outage-window scheduling theater
- no heavy backup / rollback / monitoring blockers as defaults
- no deferred “test the export” question packs that avoid deciding

Exact host/disk identity before Apply remains a **read-only discovery** gate,
not a human preference wait under `lab_recreatable_autonomy`.

## How (keep context lean)

Prefer the Light consultation sidecar: one bounded request → Expert artifact →
optional Researcher evidence check → return to the pair. Do not cold-start the
full preparation pipeline or re-ingest the transcript into Implementer context.

Skill: `onsite-expert-consultation-light-beta`  
Authority map: [02-authority--who-to-call.md](02-authority--who-to-call.md)
