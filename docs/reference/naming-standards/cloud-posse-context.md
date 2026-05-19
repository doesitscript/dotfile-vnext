# Cloud Posse Context Module Naming

## Source

- GitHub: https://github.com/cloudposse/terraform-null-label
- Terraform Registry: https://registry.terraform.io/modules/cloudposse/label/null/latest
- Cloud Posse Docs: https://docs.cloudposse.com/modules/library/null/label

## Core Philosophy

**Cloud Posse uses a strict, standardized naming convention built from 6 label elements (ID elements).**

All Cloud Posse Terraform modules use this pattern to ensure:
- Resources can be instantiated multiple times within an account without conflict
- Consistent naming across all infrastructure
- Automatic tag generation from labels
- Chaining of context between modules

## The 6 Label Elements

In order (default):

1. **namespace** — Company/organization abbreviation
2. **tenant** — Customer identifier (rarely needed)
3. **environment** — Region or environment abbreviation
4. **stage** — Account role/stage
5. **name** — Component name
6. **attributes** — List of additional modifiers

## Default Naming Convention

**Default ID format:**
```
{namespace}-{environment}-{stage}-{name}-{attributes}
```

**Examples:**
- `eg-ue1-prod-bastion-public` — namespace=eg, environment=ue1, stage=prod, name=bastion, attributes=[public]
- `acme-gbl-dev-eks-blue` — namespace=acme, environment=gbl, stage=dev, name=eks, attributes=[blue]

## Hard Requirements (MUST)

### At Least One Label

- You must provide at least one non-empty label
- All labels are technically optional
- The module generates an ID from whatever labels you provide

### Attributes as List

- `attributes` is a list of strings, not a single string
- Expands to elements joined by delimiter
- Example: `attributes = ["public", "v1"]` → `public-v1`

## Recommendations (SHOULD)

### Cloud Posse Label Conventions

**namespace:**
- Short (3-4 letters) company abbreviation
- Ensures globally unique IDs for resources like S3 buckets
- Examples: `eg`, `acme`, `cp`, `aws`

**tenant:**
- Rarely needed
- Use when provisioning dedicated resources per customer
- Examples: `customer-a`, `client-xyz`

**environment:**
- Short abbreviation for AWS region OR `gbl` for global resources
- Examples: `ue1` (us-east-1), `uw2` (us-west-2), `gbl` (global/IAM)
- See [Cloud Posse region abbreviations](https://github.com/cloudposse/terraform-aws-utils/#introduction)

**stage:**
- Account role or deployment stage
- Examples: `prod`, `staging`, `dev`, `test`, `qa`, `sandbox`

**name:**
- Component that owns the resources
- Examples: `eks`, `rds`, `vpc`, `bastion`, `lambda`

**attributes:**
- Additional modifiers for uniqueness
- Examples: `["public"]`, `["blue"]`, `["primary"]`, `["v1", "public"]`
- Discouraged to exclude — attributes ensure uniqueness

### Delimiter

- Default: `-` (hyphen)
- Configurable via `delimiter` variable
- Applied between all label elements

### Label Order

- Default order: `namespace`, `environment`, `stage`, `name`, `attributes`
- Configurable via `label_order` list
- Example custom order: `["name", "environment", "stage"]` → `bastion-ue1-prod`

### Case Control

**Label values (what goes into ID):**
- Control via `label_value_case`
- Options: `lower`, `upper`, `title`, `none`
- Default: `lower`

**Tag keys:**
- Control via `label_key_case`
- Options: `lower`, `upper`, `title`, `none`
- Default: `title`

### Maximum Length

- Set via `id_length_limit`
- Module creates unique shortened name using MD5 hash when limit exceeded
- Slight chance of collision when truncated

## Tag Generation

### Automatic Tag Export

- By default, all non-empty labels exported as tags
- `Name` tag always set to module `id` output (not `name` label)
- Empty labels never exported as tags

### Control Tag Export

**labels_as_tags:**
- List of labels to export as tags
- Empty list `[]` = no labels as tags
- Example: `["environment", "stage"]`

**Tags passed via `tags` variable:**
- Always exported
- Never modified by module
- Merge with generated tags

### Tag Key Collision

**Important:** The `name` label becomes part of the `id`, but the `Name` tag key holds the full `id`, not the `name` label value.

Example:
```hcl
namespace = "eg"
stage     = "prod"
name      = "bastion"
```

Outputs:
- `id` = `eg-prod-bastion`
- Tags: `{ Name = "eg-prod-bastion", namespace = "eg", stage = "prod" }`
- No tag with key `name`

## Context Object Pattern

### What Is Context

A single object containing all label inputs, passed between modules:

```hcl
module "base_label" {
  source = "cloudposse/label/null"
  
  namespace = "eg"
  stage     = "prod"
  name      = "app"
}

module "child_label" {
  source = "cloudposse/label/null"
  
  attributes = ["blue"]
  
  # Inherit all settings from base_label
  context = module.base_label.context
}
```

### Context Chaining Behavior

- Individual variables override context values
- Collections (tags, attributes) are merged, not replaced
- Once a non-default value is set, downstream modules inherit it
- Tags cannot be removed once added (can only be overwritten)

### labels_as_tags Exception

- Cannot be changed via context
- Set once, locked for downstream modules
- Prevents re-enabling problematic tags that conflict with AWS provider `default_tags`

## Common Patterns

### Multi-Instance Pattern

One label module per resource instance:

```hcl
module "instance_1_label" {
  source     = "cloudposse/label/null"
  namespace  = "eg"
  stage      = "prod"
  name       = "web"
  attributes = ["az1"]
}

module "instance_2_label" {
  source     = "cloudposse/label/null"
  namespace  = "eg"
  stage      = "prod"
  name       = "web"
  attributes = ["az2"]
}
```

### Shared Label Pattern

Multiple resource types share one label when logically related:

```hcl
module "app_label" {
  source    = "cloudposse/label/null"
  namespace = "eg"
  stage     = "prod"
  name      = "app"
}

resource "aws_instance" "this" {
  tags = module.app_label.tags
}

resource "aws_security_group" "this" {
  name = module.app_label.id
  tags = module.app_label.tags
}

resource "aws_s3_bucket" "this" {
  bucket = module.app_label.id
  tags   = module.app_label.tags
}
```

### Environment-Specific Overrides

```hcl
locals {
  base_context = {
    namespace = "eg"
    name      = "app"
  }
}

module "prod_label" {
  source  = "cloudposse/label/null"
  stage   = "prod"
  context = local.base_context
}

module "dev_label" {
  source  = "cloudposse/label/null"
  stage   = "dev"
  context = local.base_context
}
```

## Module Outputs

| Output | Description | Example |
|---|---|---|
| `id` | Fully formed ID string | `eg-prod-bastion-public` |
| `name` | Normalized name label | `bastion` |
| `namespace` | Normalized namespace | `eg` |
| `stage` | Normalized stage | `prod` |
| `environment` | Normalized environment | `ue1` |
| `attributes` | List of attributes | `["public"]` |
| `delimiter` | Delimiter character | `-` |
| `tags` | Map of tags | `{ Name = "...", namespace = "..." }` |
| `tags_as_list_of_maps` | Tags for ASG | `[{ key = "Name", value = "..." }]` |
| `context` | Context object for chaining | (full context) |

## Integration with AWS

### S3 Bucket Naming

```hcl
module "s3_label" {
  source      = "cloudposse/label/null"
  namespace   = "eg"
  environment = "ue1"
  stage       = "prod"
  name        = "logs"
}

resource "aws_s3_bucket" "this" {
  bucket = module.s3_label.id  # eg-ue1-prod-logs
  tags   = module.s3_label.tags
}
```

### EC2 Instance Naming

```hcl
module "instance_label" {
  source     = "cloudposse/label/null"
  namespace  = "eg"
  stage      = "prod"
  name       = "web"
  attributes = ["az1"]
}

resource "aws_instance" "this" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
  tags          = module.instance_label.tags
}
```

### Auto Scaling Group Tags

ASGs require special tag format:

```hcl
module "asg_label" {
  source    = "cloudposse/label/null"
  namespace = "eg"
  stage     = "prod"
  name      = "web"
  
  additional_tag_map = {
    propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_group" "this" {
  name = module.asg_label.id
  
  tags = module.asg_label.tags_as_list_of_maps
}
```

## Descriptors Output

For situations needing multiple ID formats from same inputs:

```hcl
module "label" {
  source = "cloudposse/label/null"
  
  descriptor_formats = {
    short = "%{name}-%{attributes}"
    long  = "%{namespace}-%{environment}-%{stage}-%{name}-%{attributes}"
  }
  
  namespace  = "eg"
  stage      = "prod"
  name       = "app"
  attributes = ["blue"]
}

# Outputs:
# descriptors = {
#   short = "app-blue"
#   long  = "eg-prod-app-blue"
# }
```

## Rationale

### Why Context Object

- Reduces verbosity (pass one object instead of 10+ variables)
- Ensures consistency across modules
- Enables easy overrides at specific points
- Standard pattern across all Cloud Posse modules

### Why Attributes as List

- Supports multiple modifiers: `["public", "v1"]`
- Order matters and is preserved
- Natural expansion with delimiter

### Why MD5 for Truncation

- Deterministic (same inputs = same hash)
- Short (only portion needed to fit limit)
- Probably unique (collision unlikely but possible)

## Anti-Patterns to Avoid

- ❌ Not providing attributes when multiple instances exist
- ❌ Using very long label values (hits length limits)
- ❌ Hardcoding IDs instead of using `label.id`
- ❌ Inconsistent labeling across related resources
- ❌ Trying to remove tags from context (they can only be overwritten)
- ❌ Relying on `name` output for resource names (use `id` instead)
- ❌ Not using context when chaining multiple label instances

## References

- GitHub: https://github.com/cloudposse/terraform-null-label
- Terraform Registry: https://registry.terraform.io/modules/cloudposse/label/null/latest
- Cloud Posse Examples: https://github.com/cloudposse/examples
- Context Pattern: https://github.com/cloudposse/terraform-null-label/blob/main/exports/context.tf
- Region Abbreviations: https://github.com/cloudposse/terraform-aws-utils/#introduction
