# Plan: `large-ide-workspace-evaluator-draft`

## Purpose

Create a reusable project-evaluation skill for detecting repository structures
that impose unnecessary IDE indexing, file-watching, search, language-server,
or AI-agent context cost.

## First-pass status

The first pass must be a **draft skill** named:

`large-ide-workspace-evaluator-draft`

It must remain explicitly draft-only until it has been exercised against more
than one project and reviewed for false positives, source-hiding behavior, and
cross-agent usefulness. The first pass must not silently promote the skill to a
general active/default skill.

## Required evaluation lanes

The draft skill must always create a separate evidence section for each of the
following locations when they exist:

1. `.venv/` — runtime dependency boundary, caches, duplicate environments, and
   tool-wrapper requirements.
2. `logs/` — generated evidence, retention, tracking, keep-file behavior, and
   explicit-path access expectations.
3. `playbooks/` — source-versus-generated content, file-type attribution,
   embedded artifacts, and accidental bulk.
4. `docs/` — source documentation, diagrams, rendered artifacts, attachments,
   and historical/generated material.

The skill must not recommend excluding an entire source directory merely from
its aggregate size. It must attribute size before recommending relocation,
ignore rules, cleanup, or layout changes.

## Cross-agent design principle

The draft skill should recommend repository/Git conventions as the shared
baseline and clearly label client-specific settings as supplemental. It must
explain that Git ignore rules reduce default discovery and accidental tracking
but do not function as access control. Explicitly named paths remain available
for deliberate investigation.

For the first Cursor-focused pass, the skill should propose or validate
targeted `.cursorignore` entries for generated/cache/evidence descendants while
preserving source `playbooks/` and `docs/`. It should not broaden the first
pass to `.venv/` until the separate runtime-boundary evaluation is complete.

## Required output

The skill should produce:

- size and file-type evidence for all four lanes;
- tracked, ignored, and untracked attribution;
- source/generated/runtime classification;
- anti-pattern findings;
- Good / Better / Best recommendations;
- Apply / Verify / Undo / Change class for proposed changes;
- a list of questions or probes required before mutation;
- an explicit statement when no safe recommendation can yet be made.

## Verification plan

- Validate the skill metadata and draft naming contract.
- Run it against `dotfile-vnext` using the repo wrapper where Python is needed.
- Run it against at least one structurally different project.
- Confirm it reports `.venv/`, `logs/`, `playbooks/`, and `docs/` separately.
- Confirm it does not propose blanket exclusion of source `playbooks/` or
  useful `docs/` without file-level evidence.
- Confirm the draft remains draft-only and is not added to the active/default
  skill routing without explicit promotion.

## Apply / Verify / Undo / Change class

| Contract | Draft skill plan |
|---|---|
| Apply | Scaffold a draft skill and test fixtures only after this evaluation is accepted |
| Verify | Metadata validation plus multi-project evaluation receipts |
| Undo | Remove the draft skill and its registration/fixtures without changing project source |
| Change class | Reusable skill scaffold; initially draft/bootstrap, not active steady-state behavior |

## Open decision

Confirm whether `large-ide-workspace-evaluator-draft` is the desired exact
title, or provide a replacement before the skill is scaffolded.
