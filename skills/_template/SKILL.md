---
name: example-skill
description: "Use when a reusable project workflow in dotfile-vnext needs a cataloged skill. Do not use for one-off notes or repo policy that belongs in AGENTS.md."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: ""
requires_summary: ""
title: Example Skill
technology: framework
document_type: skill
status: draft
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to: []
related: []
tags:
  - skill
---

# Skill: Example Skill

## When to use / not use

Use when:

- the workflow is repeatable

Do not use when:

- the task is a one-off

## Inputs

- key repo surfaces

## Workflow

1. Read the catalog entry first.
2. Follow the reusable workflow.

## Handoffs

- list adjacent skills here

## Outputs

- durable result 1

## Validation

- note the proof surface

## Failure boundaries

- stop when a prerequisite is missing

## Prohibited behavior

- inventing evidence

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Companion runtime metadata belongs in `agents/<provider>.yaml`; the current implemented provider target is `agents/openai.yaml`.
