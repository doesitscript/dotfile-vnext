# Repo Clarity Cleanup Plan

Date: 2026-03-13
Purpose: Create a cleaner foundation for future multi-agent work by separating active project material from reference material, solved examples, and aspirational exemplars.

## Why This Comes First

The current repository appears to mix:
- active implementation work
- historical or partially successful work
- downloaded reference material
- solved examples and experiments
- target-state examples from well-designed external projects

That makes it easy for a human or agent to confuse:
- source of truth vs reference
- current implementation vs aspirational pattern
- trusted example vs abandoned draft

The immediate goal is not a code rewrite. The goal is to improve context quality so future work is easier, more accurate, and less fragile.

## Recommended Pattern

Use a clear source-separation pattern:
- active project
- internal library
- external exemplars
- archive / quarantine

This is the right first move because it increases signal-to-noise without forcing risky code changes.

## Phase 1: Repo Mapping

Goal: identify what exists before moving anything.

Tasks:
- inventory the top-level functional areas of the repository
- identify current source-of-truth locations
- identify duplicated or overlapping material
- identify likely abandoned or low-confidence work
- identify downloaded external references
- identify solved examples worth preserving
- identify candidate exemplar repos or folders worth modeling

Deliverable:
- a simple classification map of the repo by folder and purpose

## Phase 2: Classification Model

Goal: define a small number of labels that make future reasoning safer.

Recommended classifications:
- `active` — current project code and docs
- `reference-internal` — notes, examples, and prior solved work created or adapted for this repo
- `reference-external` — downloaded or copied material from other repositories
- `exemplar` — high-quality patterns we intentionally want to emulate
- `archive` — obsolete, confusing, superseded, or low-trust material
- `scratch` — temporary experiments not yet promoted

Deliverable:
- one short index doc describing these labels and how to use them

## Phase 3: Structural Cleanup

Goal: make the repository easier to navigate without changing active behavior.

Proposed cleanup moves:
- keep the active project paths clearly separated from references
- create a dedicated library area for collected reference material
- create a dedicated exemplar area for trusted good designs
- move confusing or deprecated content into archive or quarantine paths
- reduce naming ambiguity where multiple files suggest the same authority

Suggested target zones:
- `project/` or current active paths retained as source of truth
- `library/internal/` for solved examples and notes
- `library/external/` for downloaded repos or extracted references
- `library/exemplars/` for high-quality patterns to emulate
- `archive/` for low-trust or obsolete material

Note:
We should prefer minimal movement at first. Renames and relocations should happen only after classification is clear.

## Phase 4: Trust Index

Goal: declare what should guide future implementation.

Create a short document that answers:
- what is the current source of truth for active work
- which references are trusted
- which exemplars should influence design decisions
- which paths are reference-only and should not be copied blindly
- which paths are archived and should be ignored unless explicitly needed

Deliverable:
- a `repo-context-index` style document for humans and agents

## Phase 5: Cleanup For Agent Readability

Goal: reduce future agent confusion.

Improvements:
- label folders by intent, not history
- remove ambiguous duplicates where practical
- add README files in key directories
- document source-of-truth locations
- document target exemplars and what they demonstrate
- document anti-pattern areas or low-confidence legacy material

Deliverable:
- small README or index files in the most important zones

## Phase 6: Curated Example Strategy

Goal: build a reference library that actually helps implementation.

Recommended categories:
- ansible role examples
- inventory design examples
- playbook orchestration examples
- windows automation examples
- linux automation examples
- mcp / multi-agent / tooling examples

For each saved example, capture:
- what it demonstrates
- why it is trusted
- when to use it
- what not to copy directly

Deliverable:
- a curated example library with short summaries

## Phase 7: Exemplar Comparison

Goal: compare this repo to a small number of strong target projects.

Comparison dimensions:
- folder structure
- role boundaries
- inventory organization
- variable naming and scoping
- playbook composition
- docs quality
- source-of-truth clarity

Deliverable:
- a short gap analysis:
  - what this repo already does well
  - what to borrow
  - what to avoid
  - what to change later

## Immediate Next Steps

Recommended first working session:
1. map the repository into active, reference, exemplar, archive, and scratch
2. identify the worst confusion hotspots
3. define the desired folder taxonomy
4. make only the smallest structural moves needed to improve clarity
5. add index docs so future work has context anchors

## What We Should Not Do First

Avoid starting with:
- broad refactors of active Ansible content
- style-only rewrites
- aggressive renaming without classification
- deleting confusing material before we understand its role
- copying external patterns directly into active code

## Success Criteria

This cleanup is successful when:
- the active project is easy to identify
- reference material is clearly separated from source of truth
- exemplar material is intentionally curated
- archived or low-trust material no longer pollutes normal reasoning
- future agent sessions can understand the repo faster and with fewer wrong assumptions

## Recommended Follow-On

After the clarity cleanup, create repository-specific multi-agent roles:
- planner
- researcher
- implementer
- reviewer
- pattern-comparer

Those roles will work much better once the repository has cleaner boundaries and a documented trust model.
