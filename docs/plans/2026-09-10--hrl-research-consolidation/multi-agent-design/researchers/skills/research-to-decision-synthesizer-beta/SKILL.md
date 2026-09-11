---
name: research-to-decision-synthesizer-beta
description: Convert a nominated Expert research document and verified current-state evidence into bounded decision packets for Planner and Expert iteration. Use during planning; do not implement infrastructure or treat technical guidance as Apply authority.
metadata:
  status: beta
  scope: research-application-planning
  workflow_id: guided-research-application
  role: research-synthesizer
  counterpart_roles: onsite-expert, planner-coordinator
---

# Research-to-decision Synthesizer — beta

Use this project-local skill when a supplied Expert document, research pack, or
user/Expert collaboration needs to become a reusable planning input. It is not
for re-researching the whole topic or writing infrastructure changes.

## Inputs

Require the nominated source document, canonical plan/campaign location, the
Expert's decision questions, durable user constraints, and relevant current
receipts/configuration/topology evidence. Preserve the source document as
provenance; do not overwrite it or mistake a transcript for a plan.

## Produce a bounded packet

Classify each relevant finding as one of: hard correction, placement/design
principle, durability/safety prohibition, conditional option, or required
discovery/validation. For each decision question, cite evidence and current
surfaces, alternatives, assumptions, expected benefit, proof metric, and the
next consumer. Keep general Expert guidance general: a recommendation such as
“use a fast tier for latency-sensitive storage” is a constraint to be mapped by
Planner/Implementer, not a forced device path or shell command.

Write the packet beneath the campaign's `coordination/research-application/`
area. Include a short receipt that names source, user/Expert collaboration,
packet paths, and the existing canonical plan artifacts updated or awaiting
update. Follow [the guided research-application loop](../../../research-application-loop.md).

## Iterate with the Expert

Return only a named ambiguity: unsupported conclusion, competing owner mapping,
stale/missing fact, unmeasurable benefit, or conflict with a safety boundary.
Incorporate the Expert's response as a new bounded pass. Stop when the packet
answers the decision questions or names the exact unresolved evidence.

## Boundaries

Do not choose Apply authority, edit implementation sources, bind an unknown
physical target, or declare technical research to be an Evaluator-approved plan.
The current beta runtime does not auto-schedule this skill; it is a bootstrap
and next-iteration capability invoked through durable artifacts.

For a concrete project example, read
[storage-performance-research-application.md](../../../multi-agent-onsite-expert/examples/storage-performance-research-application.md)
and its [bootstrap packet](../../../../implementation-campaign/coordination/research-application/performance-layout-bootstrap-2026-09-11/README.md).
Use them as a demonstration of the contract, not as an authority to apply their
specific technical choices to another campaign.
