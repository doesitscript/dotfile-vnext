# Pattern Extraction: Knowledge Gates

## Reusable Pattern

The reusable pattern is a knowledge gate:

1. identify the task domain
2. load repo truth first
3. load current authoritative domain docs
4. discover schemas, modules, or tool capabilities before choosing an approach
5. emit a knowledge receipt before decision-complete planning or implementation

## Why This Is Split Into Three Capabilities

Ansible and NetBox improve the project through different authority models.
Bundling them into one skill would make the capability harder to service and
would hide whether a task needs automation guidance, infrastructure modeling
guidance, or both.

The split is:

- Ansible knowledge gate: automation design and validation.
- NetBox knowledge gate: infrastructure source-of-truth modeling.
- Project maturity router: broad request classification and composition.

## Trigger Model

- Ansible-only work triggers the Ansible gate.
- NetBox-only work triggers the NetBox gate.
- Broad project-maturity work triggers the router, which decides whether to
  invoke Ansible, NetBox, or both.

## Required Receipt Shape

Every gated response should include or prepare:

- repo surfaces checked
- authoritative docs checked
- schema/tool discovery performed
- design impact
- open gaps
- apply/verify/undo/change class when implementation is in scope
