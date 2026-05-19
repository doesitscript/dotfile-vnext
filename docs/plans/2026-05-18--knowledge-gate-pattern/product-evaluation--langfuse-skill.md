# Product Evaluation: Langfuse Skill Knowledge Enforcement

## Evaluation Target

- Project: Langfuse skills
- Source:
  `https://github.com/langfuse/skills/blob/8e6c2d02accefc0dad3b7d3be3751f7fcc210885/skills/langfuse/SKILL.md`
- Commit: `8e6c2d02accefc0dad3b7d3be3751f7fcc210885`
- Evaluation date: 2026-05-18
- Purpose: preserve the source/product evaluation that inspired this repo's
  modular knowledge-gate pattern.

## Evaluation

The Langfuse skill's strength is not magic enforcement; it is a tight knowledge
acquisition contract repeated at every layer.

Sources checked during the original evaluation:

- Langfuse skill `SKILL.md`: broad trigger metadata, allowed tools, "NEVER
  implement based on memory", docs-first workflow, CLI schema discovery, and
  use-case references.
- Langfuse Agent Skill docs: progressive disclosure means metadata is visible
  first, then full skill and references load on demand.
- OpenAI Codex customization docs: skills are best for reusable workflows and
  domain expertise; pair skills with MCP/docs servers when external systems
  matter.
- NetBox Labs AI/LLM docs entry points: NetBox publishes `llms.txt`,
  `llms-full.txt`, and API docs for LLM grounding.
- This repo's framework rules: the repo already had the skeleton in
  `framework-knowledge-and-research.mdc`, `framework-netbox-modeling.mdc`,
  `framework-ansible-mcp-usage.mdc`, and Ansible standards.

## Four Enforcement Moves Worth Copying

1. Make ignorance illegal in the skill itself.
   The skill says not to implement based on memory and to fetch current docs
   before writing code. That is stronger than "prefer docs" because it makes
   ungrounded implementation a rule violation.

2. Provide a deterministic learning path.
   It does not merely say "read the docs." It gives an exact sequence: fetch
   `llms.txt`, pick relevant pages, fetch markdown pages, and use search as
   fallback.

3. Split general rules from use-case playbooks.
   The main skill stays small, then points to references for specific
   workflows. In this repo that maps to Ansible role design, Ansible
   verification, NetBox modeling, NetBox inventory, and source-of-truth
   transitions.

4. Force schema/tool discovery before action.
   Langfuse makes agents discover CLI schema/help before API usage. This repo's
   equivalent is: inspect repo surfaces, use `ansible-doc`, MCP, and
   best-practice docs, then check NetBox object docs/API/schema before design.

## Limitation And Repo Adaptation

A skill can strongly condition behavior, but it cannot guarantee the model
became knowledgeable unless visible proof is required. This repo should make
that proof explicit through a knowledge receipt:

- sources checked
- docs pages used
- repo surfaces inspected
- design implications
- open gaps

This is the enforcement layer the Langfuse skill implies and this repo makes
explicit.

## Status

This file is pure source/product evaluation. It is not the implementation spec.
The adapted implementation lives in the sibling capability files in this plan
packet.
