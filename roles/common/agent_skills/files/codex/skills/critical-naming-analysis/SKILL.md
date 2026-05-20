---
name: critical-naming-analysis
description: Perform critical infrastructure naming analysis before renaming, creating, or recommending names for hosts, VMs, NetBox objects, services, roles, inventories, repositories, or resources.
---

# Critical Naming Analysis

Use this skill whenever a resource name is created, updated, challenged, or
reevaluated.

## Required Order

1. Gather current repo and source-of-truth facts.
2. Load the local schema registry first:
   `docs/reference/naming-standards/`.
3. Classify every current and proposed name segment.
4. If NetBox is involved, compare current and proposed native fields, tags,
   config context, and legacy aliases.
5. If the schema lacks the resource family, declare the gap and research the
   approved references before proposing a new code.
6. Reject names that encode historical accidents, mutable policy, IPs,
   temporary state, platform, owner names, or undefined acronyms.
7. Recommend one name and list the required repo, NetBox, and documentation
   cleanup steps.

## Current Local Baseline

```text
<tenant>-<environment>-<domain>-<role>-<idx>
```

Example:

```text
hom-lab-ctl-hvh-01
```

Field decisions:

- Context codes are normally 2-3 characters.
- `idx` is the canonical two-digit ordinal field.
- Imported `seq`, `sequence`, and `nn` normalize to `idx`.
- `ctl` replaces `auth`/`aut` for control-plane or management infrastructure.
- Compact slugs/codes are used for repo-controlled code objects.
- Longer friendly meaning belongs in descriptions or schema metadata.

## Approved Research Sources For Gaps

Do not use training-data-only naming guesses when the local schema has a gap.
Research from approved sources first:

- Cloud Posse terraform-null-label: https://github.com/cloudposse/terraform-null-label
- Terraform Registry Cloud Posse label module: https://registry.terraform.io/modules/cloudposse/label/null/latest
- Cloud Posse examples: https://github.com/cloudposse/examples
- Cloud Posse context pattern: https://github.com/cloudposse/terraform-null-label/blob/main/exports/context.tf
- Cloud Posse region abbreviations: https://github.com/cloudposse/terraform-aws-utils/#introduction
- Kubernetes community: https://github.com/kubernetes/community
- Terragrunt documentation: https://terragrunt.gruntwork.io/
- Terragrunt quick start: https://terragrunt.gruntwork.io/docs/getting-started/quick-start/
- Gruntwork infrastructure live example: https://github.com/gruntwork-io/terragrunt-infrastructure-live-example

## Output Shape

```yaml
current:
  object:
    current_name:
    legacy_aliases: []
  netbox:
    site:
    tenant:
    role:
    platform:
    tags: []
    config_context: {}
candidate:
  name:
  schema: "<tenant>-<environment>-<domain>-<role>-<idx>"
  fields:
    tenant:
    environment:
    domain:
    role:
    idx:
classification:
  reusable_segments: []
  rejected_segments: []
schema_gap:
  exists: false
  resource_family:
recommendation:
  selected_name:
  required_cleanup: []
  override_rationale:
```
