# NetBox And Infrastructure Authority

## External sources

- `https://context7.com/docs/adding-libraries`
- `https://context7.com/docs/howto/private-sources`
- `https://context7.com/docs/resources/all-clients`

## Repo authority sources

- `/Users/joshc/develop/dotfile-vnext/AGENTS.md`
- `/Users/joshc/develop/dotfile-vnext/README.md`
- `/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md`

## Suggested pattern from upstream

Context7 can index documentation repositories and private documentation sources
so coding agents can pull current documentation into context.

That is useful for:

- Langfuse docs and cookbooks
- repo design-pattern docs
- supporting NetBox docs or OpenAPI context

## Repo adaptation

In this repo, Context7 is documentation context only.

Use Context7 for:

- `/langfuse/langfuse-docs`
- repo design-pattern documentation if private-source indexing is available
- NetBox docs or OpenAPI context if needed for supporting implementation

Do not use Context7 for live authority over:

- host placement
- VM identity
- service ownership
- current topology
- live NetBox object state

Those remain owned by:

- NetBox modeled truth
- repo naming/schema rules
- repo playbook and retrospective evidence

## Conflicts with current infrastructure

- documentation indexing is not the same thing as infrastructure truth
- cookbook/source indexing cannot replace live NetBox or repo reconciliation
- context systems can describe services but cannot declare current authoritative
  placement

## Decision for this project

- allow Context7 to support documentation adaptation
- keep NetBox MCP/API and repo docs as infrastructure truth
- explicitly document this split so future example work does not confuse docs
  context with live authority

## Open verification items

- whether repo design-pattern docs will actually be onboarded as a Context7
  private source
- whether NetBox OpenAPI/docs are worth indexing for this slice
- whether a future packet should formalize a repeatable private-source indexing
  workflow for repo-owned design docs
