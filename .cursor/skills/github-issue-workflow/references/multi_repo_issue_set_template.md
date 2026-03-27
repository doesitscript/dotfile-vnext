# Multi-Repo Issue Set Template

Use this pattern when one repo owns the main product or feature outcome and a
second repo owns supporting automation, framework, or process work.

## Repo roles

- `primary`
  Main issue in the product repo.
- `secondary`
  Supporting issue in another repo.
- `reference_only`
  Repo or document source that informs the issue set but does not get an issue
  by default.

## Default relationship mode

Use `supporting_tracking` unless the work is clearly:

- `parent_child`
- `blocking_dependency`

## Primary issue body shape

```md
Overview:
Describe the main product or feature outcome.

Why this issue lives here:
- explain why the primary repo is the right home

Cross-repo issue map:
- [ ] <secondary issue link> — supporting work in <secondary repo>

Primary execution plan:
- item 1
- item 2

Definition of done:
- outcome 1
- outcome 2

Pick-up references:
- repo-local file/path 1
- repo-local file/path 2
- reference-only context path if needed
```

## Secondary issue body shape

```md
Overview:
Describe the supporting work this repo owns.

Why this issue lives here:
- explain why the supporting repo is the right home

Primary issue link:
- <primary issue link>

Local execution plan:
- item 1
- item 2

Definition of done:
- outcome 1
- outcome 2

Pick-up references:
- local file/path 1
- local file/path 2
- reference-only context path if needed
```

## Creation order

1. confirm repo-role mapping
2. ensure required labels exist
3. create primary issue
4. create secondary issue
5. update primary issue with final tasklist reference
6. update secondary issue with final primary link if needed

## Label pattern

Required:

- one `type:*`
- one `state:*`
- one `scope:*`

Optional when useful:

- `coordination:cross-repo`
- `repo-role:primary`
- `repo-role:secondary`
