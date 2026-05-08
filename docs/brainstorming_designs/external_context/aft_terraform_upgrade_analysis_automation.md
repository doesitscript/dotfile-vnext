# AFT Terraform Upgrade Analysis Automation

This note captures a design target for automating Terraform upgrade analysis for an AFT estate.

The intended outcome is not "an agent that reads release notes and gives an opinion."

The intended outcome is a repeatable analysis pipeline that:

1. inventories what our repos actually use
2. gathers only the upstream changes relevant to the chosen upgrade window
3. matches those upstream changes against our repo facts
4. produces a concise human report plus a manual-review queue

The design is AI-leaning, but not AI-led in the wrong places. Deterministic parsing and matching should own facts. AI should help where prose interpretation, extraction, summarization, and ambiguous reasoning actually benefit from it.

## Problem Statement

Upgrading Terraform in AFT is easy to describe and easy to bloat.

The simple form is:

1. pick a current version
2. pick a target version
3. collect upstream changes between them
4. determine which of those changes affect our repos
5. produce an upgrade-impact report

The failure mode is turning that into a loose research project, prose-heavy notes, or an execution plan that mixes planning and implementation too early.

This design exists to keep the process stable, auditable, and automatable.

## Design Goals

- **Deterministic where truth matters**
  - Repo facts, version ranges, file inventory, provider constraints, module sources, resource types, and lockfile presence should come from code and filesystem parsing, not from model interpretation.

- **AI where prose is messy**
  - Release notes, changelogs, upgrade guides, and vague behavior changes are where a model adds real value, as long as it is extracting into a strict schema instead of writing an essay.

- **Separation of facts from judgments**
  - Repo inventory, upstream changes, and applicability decisions should live in different artifacts.

- **Concise final report**
  - The final report should not be a dump of notes. It should answer what matters, what does not, and what still needs review.

- **Repeatable per upgrade window**
  - Change `current_version` and `target_version`, rerun the pipeline, and get a new report without redesigning the process.

- **Trust-preserving evidence chain**
  - Every meaningful conclusion should be traceable back to source documents and observed repo facts.

## Non-Goals

- **Not a runtime validation engine**
  - `terraform init`, `terraform validate`, `terraform plan`, and sandbox pipeline runs belong to a follow-on execution phase.

- **Not a general Terraform refactoring assistant**
  - The first version should assess impact, not automatically rewrite HCL.

- **Not "AI decides if upgrade is safe"**
  - AI can help classify and explain, but the pipeline should preserve the raw evidence and the reason for each conclusion.

## Core Architecture

### 1. Inputs Layer

- **Purpose**
  - Define the analysis window and scope.

- **Contents**
  - current Terraform version
  - target Terraform version
  - current AFT module version
  - target AFT module version, if in scope
  - repo paths
  - optional provider/module scope overrides

- **Why this matters**
  - The system should be rerunnable by changing one input surface instead of editing multiple documents.

### 2. Repo Inventory Layer

- **Purpose**
  - Capture what the repos actually contain.

- **What it should inventory**
  - `required_version` constraints
  - provider constraints
  - lockfiles and whether provider resolution is fixed or unresolved
  - backend definitions, including templated backends
  - module source types: local vs external
  - resource types in use
  - data sources in use
  - provisioners, lifecycle blocks, and other special constructs
  - Terraform functions or patterns likely to intersect with upgrade notes
  - repo-specific manual-review hotspots

- **Why this matters**
  - This is the anchor that prevents generic release-note review from turning into noise.

### 3. Source Manifest Layer

- **Purpose**
  - Decide what upstream documents need to be fetched for this run.

- **How it should decide**
  - Terraform core minor versions between current and target are always in scope.
  - AFT release notes are in scope.
  - AWS provider release notes are in scope if the repos use the AWS provider.
  - External module release notes are only in scope if the repo inventory proves external modules are present.

- **Why this matters**
  - This avoids doing research lanes that are not actually relevant to the estate.

### 4. Source Fetch and Cache Layer

- **Purpose**
  - Save fetched source documents locally so the run is reproducible and reviewable.

- **What to cache**
  - Terraform release notes or changelog pages
  - AWS provider changelog or release-note entries
  - AFT release notes and `versions.tf` snapshots
  - external module docs only if required

- **Why this matters**
  - A good evidence chain should not disappear after one chat session or one HTTP call.

### 5. Structured Change Extraction Layer

- **Purpose**
  - Turn messy upstream prose into normalized change records.

- **Where AI fits**
  - This is the first place I would deliberately use AI.

- **Expected output per change**
  - source surface
  - version introduced
  - change type
  - short summary
  - citation
  - scope hint
  - match hints such as resource types, backends, provider behaviors, or version boundaries

- **Why this matters**
  - Release notes are written for humans. The pipeline needs machine-usable records.

### 6. Deterministic Matching Layer

- **Purpose**
  - Compare structured upstream changes against the repo inventory.

- **How it should work**
  - rule-based matching first
  - simple pattern matching second
  - AI adjudication only for cases that remain ambiguous

- **Typical deterministic matches**
  - backend-specific change -> repo uses that backend
  - resource-specific provider change -> repo uses that resource type
  - module-source change -> repo uses that external module
  - minimum-version bump -> repo/provider constraints overlap or conflict

- **Why this matters**
  - This is the real engine. If this layer is weak, the whole process becomes vibes.

### 7. Ambiguity and Manual-Review Layer

- **Purpose**
  - Hold cases that should not be forced into fake certainty.

- **Examples**
  - provider lower bounds exist but no lockfile pins the selected version
  - release notes describe a behavior change too vaguely for deterministic matching
  - templated code implies a pattern that needs runtime confirmation
  - an issue might apply only if a resource argument is populated a certain way

- **Why this matters**
  - Good automation should elevate ambiguity, not hide it.

### 8. Report Generation Layer

- **Purpose**
  - Produce the human-readable output for review and decision-making.

- **What the report should include**
  - upgrade window summary
  - applicable breaking or behavior-changing items
  - reviewed and not applicable items
  - manual-review items
  - follow-up actions
  - explicit boundary between planning and execution

- **Why this matters**
  - Most consumers do not need the entire machine state. They need a defensible summary.

## AI vs Deterministic Responsibilities

### AI Should Do

- **Normalize prose**
  - Extract structured change records from release notes and upgrade guides.

- **Generate match hints**
  - Suggest likely resource types, patterns, or surfaces implied by a change entry.

- **Explain ambiguous cases**
  - Produce concise rationales when the evidence supports multiple interpretations.

- **Draft concise report language**
  - Convert structured assessment output into readable review text.

### AI Should Not Do

- **Invent upstream changes**
  - If it was not fetched, it is not real for this pipeline.

- **Guess repo facts**
  - Repo facts come from scanning and parsing.

- **Guess resolved provider versions**
  - Wide constraints without a lockfile are a manual-review signal, not permission to assume.

- **Overrule deterministic evidence**
  - If the parser says a resource type is absent, AI should not claim the change applies.

## Data Model

### `inputs.yaml`

- **Purpose**
  - Human entry point.

- **Key fields**
  - `terraform.current_version`
  - `terraform.target_version`
  - `aft.current_module_version`
  - `repos[]`
  - `active_files`

### `repo-inventory.yaml`

- **Purpose**
  - Observed facts only.

- **Key sections**
  - Terraform constraints
  - provider constraints
  - lockfile presence
  - backend files
  - module sources
  - resource types
  - data sources
  - constructs to check
  - manual-review areas

### `breaking-changes.yaml`

- **Purpose**
  - Sourced upstream changes only.

- **Key fields per change**
  - `id`
  - `source_surface`
  - `version_introduced`
  - `change_type`
  - `summary`
  - `source_url`
  - `source_section`
  - `match_hints`

### `impact-assessment.yaml`

- **Purpose**
  - Applicability decisions.

- **Allowed statuses**
  - `applicable_action_required`
  - `applicable_no_action`
  - `not_applicable`
  - `manual_review`

- **Required evidence**
  - upstream citation
  - repo-side evidence
  - rationale
  - follow-up action type

### `manual-review.yaml`

- **Purpose**
  - Optional but recommended queue for unresolved items.

- **Why I would add it**
  - It keeps unresolved questions from being buried inside the larger assessment file or final report.

## Implementation Shape

### Orchestration

- **Pattern**
  - Small CLI with explicit pipeline stages.

- **Commands I would want**
  - `analyze inventory`
  - `analyze fetch`
  - `analyze extract`
  - `analyze assess`
  - `analyze report`
  - `analyze all`

- **Why this matters**
  - A staged pipeline is easier to trust, rerun, and debug than one monolithic agent pass.

### Language and Runtime

- **Recommendation**
  - Python.

- **Why**
  - Strong ecosystem for YAML, structured data, CLI tooling, HTTP fetch, and HCL-related parsing options.

- **Additional note**
  - Keep the runtime wrapper story explicit if this ever lives inside `dotfile-vnext`, especially if execution later touches repo-local Python or Terraform tooling.

### Parsing Strategy

- **Recommendation**
  - Use a real HCL parser where practical, plus narrow fallback scanning for templated or edge-case files.

- **Why**
  - Regex-only parsing will fail once the repos get more varied.

- **Exception**
  - Some templated files or partial snippets may still need pattern matching rather than full parsing.

### Caching Strategy

- **Recommendation**
  - Cache raw sources and normalized outputs separately.

- **Why**
  - This allows rerendering and rematching without refetching everything, and allows re-extraction if prompts or schemas improve.

## Matching Strategy

### Match Types

- **Exact structural match**
  - Example: release note calls out `aws_db_instance`; repo inventory includes `aws_db_instance`.

- **Category match**
  - Example: backend `s3` behavior change; repo inventory includes S3 backend usage.

- **Constraint/version match**
  - Example: minimum Terraform or provider version bump intersects with current constraints.

- **Potential semantic match**
  - Example: change references a behavior pattern that might apply depending on resource arguments or runtime values.

### Rule Priorities

- **Priority 1: hard deterministic matches**
  - Resource type, backend, provider family, module source, file presence.

- **Priority 2: pattern-based hints**
  - Function names, lifecycle constructs, templated backend use, known deprecated patterns.

- **Priority 3: AI adjudication**
  - Use only when the first two layers cannot resolve confidently.

## Trust and Review Model

### Evidence Preservation

- **Rule**
  - Every meaningful applicability decision should be traceable to:
    - one upstream citation
    - one repo-side fact

- **Why**
  - If a teammate challenges the report, the system should show why the decision was made.

### Manual Review Is a Feature

- **Rule**
  - The system should prefer `manual_review` over false certainty.

- **Why**
  - The worst automation outcome here is a smooth-looking wrong answer.

### Human Review Surface

- **Recommendation**
  - The final report should be short enough to read quickly, but the structured artifacts should remain available for audit.

## Example Workflow

1. set `current_version` and `target_version`
2. scan the repos and produce inventory
3. build a source manifest from the inventory plus the requested upgrade window
4. fetch the relevant upstream documents
5. extract structured changes from those sources
6. run deterministic matching
7. send unresolved cases through AI adjudication or mark `manual_review`
8. generate the final report
9. only after report approval, move into runtime validation and implementation

## Why This Fits AFT Upgrade Work

- **The scope is bounded**
  - AFT upgrade analysis usually centers on a small set of repos and a clear version window.

- **The estate is structured**
  - Terraform and provider usage can be inventoried predictably.

- **Release notes are noisy**
  - AI can provide real value in normalizing prose-heavy source material.

- **The human output needs to stay concise**
  - Teams do not want the full release-note corpus. They want a defensible impact summary.

## Suggested v1 Scope

- **In scope**
  - Terraform core changes across skipped minor versions
  - AFT module compatibility
  - AWS provider compatibility
  - external module compatibility only when inventory proves it matters
  - repo inventory for constraints, resource types, module sources, and lockfiles
  - structured final report generation

- **Out of scope**
  - automatic HCL rewrites
  - execution-phase `terraform plan` automation
  - PR generation
  - auto-fixing provider constraints

## Suggested v2 Additions

- **Deeper provider/resource matching**
  - Check resource arguments, not just resource type presence.

- **Execution-phase bridge**
  - Add a separate pipeline that takes the approved report and runs validation.

- **Cross-upgrade memory**
  - Track recurring manual-review patterns or repo exceptions over time.

- **Prompt and rule tuning**
  - Improve extraction quality as more source material is encountered.

## Risks

- **Messy release notes**
  - Some upstream sources are inconsistent in wording, structure, or specificity.

- **Templated repo surfaces**
  - Generated or templated Terraform files may require custom handling.

- **False confidence from broad constraints**
  - Lower-bound-only provider constraints can look safer than they are.

- **Overuse of AI**
  - If AI is allowed to classify without evidence, trust collapses fast.

## Strongest Design Opinion

The right pattern is not:

- one smart agent reads everything
- writes a long note
- and decides what matters

The right pattern is:

- deterministic compiler-style pipeline
- structured artifacts at each stage
- AI used as a controlled extraction and explanation component
- concise report generated from evidence-backed assessments

That is the version I would trust enough to invest in.

## Open Questions For Later Review

- Should the first implementation live as a standalone tool or as a repo-local helper under a broader automation repo?
- Should normalized change records stay in YAML, JSON, or a lightweight SQLite store?
- How much of the matching layer should be configurable rules versus hardcoded logic?
- Should execution-phase validation remain a separate tool or become a second pipeline stage once planning is stable?
- Would a small web or TUI review surface be useful for triaging `manual_review` items, or is Markdown plus YAML enough?
