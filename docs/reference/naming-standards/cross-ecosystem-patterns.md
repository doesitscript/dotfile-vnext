# Cross-Ecosystem Naming Patterns

## Purpose

Common naming principles and patterns that emerge across NetBox, Kubernetes, Ansible, Docker, AWS, Cloud Posse, and Terragrunt. Use these universal patterns as a foundation when naming resources in any system.

## Universal Principles

### 1. Lowercase Preferred

**Consensus across systems:**
- Kubernetes: MUST be lowercase
- Docker: MUST be lowercase (repository names)
- Ansible: SHOULD be lowercase
- NetBox: Recommended lowercase for slugs
- AWS S3: MUST be lowercase
- Terragrunt: Recommended lowercase

**Exceptions:**
- Docker tags: CAN be mixed case
- AWS tag values: Case-sensitive, organization choice
- Proper product names: Preserve vendor casing

**Recommendation:** Default to lowercase unless you have a specific reason not to.

### 2. Hyphens for Human-Readable Names

**Consensus:**
- Kubernetes: Uses hyphens (DNS-compliant)
- Docker: Uses hyphens
- NetBox: Uses hyphens for slugs
- Cloud Posse: Uses hyphens (default delimiter)

**Exceptions:**
- Ansible: Uses underscores (Python identifier compatibility)
- File paths: System-dependent

**Recommendation:** Use hyphens for external/user-facing names. Use underscores for code identifiers (variables, role names).

### 3. Short and Descriptive

**Pattern:** `<primary-function>` or `<function>-<qualifier>`

**Good:**
- `web`, `api`, `database`, `cache`
- `web-frontend`, `api-gateway`, `mysql-primary`

**Avoid:**
- `my-application-for-processing-customer-data`
- `server-that-handles-web-requests`

**Rationale:** Names appear in logs, CLI output, UIs. Short names are faster to read and type.

### 4. Hierarchical Information Goes in Structure, Not Names

**Don't encode hierarchy in names:**
```
❌ prod-us-east-1-web-frontend-app-v1-public
```

**Use structure instead:**
```
✅ Directory:  prod/us-east-1/services/
   Name:       frontend-app
   Tags:       version=1, visibility=public
```

**Rationale:** Names become unmanageable at scale. Use directories, namespaces, tags, and fields for organization.

### 5. Uniqueness Scope

Different systems have different uniqueness requirements:

| System | Uniqueness Scope |
|---|---|
| Kubernetes | Within namespace + resource type |
| Docker | Repository globally unique, tags per repository |
| NetBox | Device names unique per site (unless tenanted) |
| Ansible | Role names unique per collection |
| AWS S3 | Bucket names globally unique |
| AWS EC2 | Name tag not enforced unique |

**Recommendation:** Understand your system's uniqueness scope. Use qualifiers (`-01`, `-primary`, `-blue`) when creating multiple instances.

### 6. Semantic Components

**Pattern:** `<function>-<qualifier>-<instance>`

**Examples:**
- `web-frontend-01`
- `database-primary`
- `cache-redis-master`
- `api-gateway-public`

**Component meanings:**
- Function: What it does (`web`, `api`, `database`)
- Qualifier: Type or role (`frontend`, `backend`, `primary`, `replica`)
- Instance: Distinguisher (`01`, `02`, `master`, `blue`)

## Common Cross-System Patterns

### Environment Naming

**Standard environments across systems:**

| Environment | Kubernetes Namespace | AWS Account/Tag | Directory Name | Description |
|---|---|---|---|---|
| Production | `production` or `prod` | `Production` | `prod/` | Live customer-facing |
| Staging | `staging` or `stage` | `Staging` | `staging/` | Pre-production validation |
| Development | `development` or `dev` | `Development` | `dev/` | Active development |
| QA/Testing | `qa` or `testing` | `QA` | `qa/` | Quality assurance |
| Sandbox | `sandbox` | `Sandbox` | `sandbox/` | Experimental |

**Recommendation:** Pick one variant per environment and use it everywhere. Avoid mixing `prod` and `production`.

### Region/Location Naming

**AWS Region Codes (used across systems):**
- `us-east-1`, `us-west-2`, `eu-west-1`, `ap-southeast-1`

**Abbreviated (Cloud Posse style):**
- `ue1`, `uw2`, `euw1`, `apse1`

**Global Resources:**
- `global` or `gbl` (IAM, Route53, CloudFront)

### Component Function Names

**Common component types:**

| Function | Example Names | Used For |
|---|---|---|
| Web servers | `web`, `nginx`, `frontend` | HTTP/HTTPS serving |
| APIs | `api`, `backend`, `rest-api`, `graphql` | Application APIs |
| Workers | `worker`, `processor`, `job-runner` | Background jobs |
| Databases | `mysql`, `postgres`, `mongo`, `database` | Data storage |
| Caches | `redis`, `memcached`, `cache` | Caching layers |
| Queues | `rabbitmq`, `sqs`, `queue` | Message queuing |
| Load Balancers | `lb`, `alb`, `nlb`, `ingress` | Traffic distribution |
| Storage | `storage`, `s3`, `nas`, `san` | File/object storage |

### Instance Numbering

**Patterns:**
- Two-digit: `01`, `02`, `03` (preferred)
- Single-digit: `1`, `2`, `3` (acceptable)
- Named: `primary`, `secondary`, `standby`
- Colors: `blue`, `green` (blue/green deployments)
- Zones: `az1`, `az2`, `az3` (availability zones)

**Avoid:**
- Random: `a1b2c3`, `xk9sd`
- Sequential without leading zeros: `1`, `10`, `2` (sorts incorrectly)

### Role Naming

**Patterns:**
- `master` / `primary` (avoid `master`, prefer `primary`)
- `worker` / `node`
- `coordinator` / `follower`
- `active` / `standby`

### State/Lifecycle Labels

**Common states:**
- `active`, `inactive`
- `enabled`, `disabled`
- `running`, `stopped`
- `healthy`, `unhealthy`
- `present`, `absent` (Ansible)

## Tag/Label Patterns Across Systems

### Standard Tag Keys

These tag/label keys work across multiple systems:

| Key | Values | Systems | Purpose |
|---|---|---|---|
| `Name` | Human-readable name | AWS, NetBox | Display name |
| `name` | Component identifier | Kubernetes | Resource identifier |
| `Environment` | prod, staging, dev | AWS, NetBox | Environment segregation |
| `environment` | prod, staging, dev | Kubernetes | Environment label |
| `Application` or `app` | Application name | All | Application grouping |
| `Version` or `version` | Semver or commit SHA | All | Version tracking |
| `Owner` | Email or team | AWS, NetBox | Ownership |
| `ManagedBy` | Terraform, Ansible, etc. | AWS, NetBox | Automation tool |
| `CostCenter` | Billing code | AWS | Cost allocation |
| `Component` | Component type | Kubernetes | Workload component |
| `tier` | frontend, backend, data | Kubernetes | Application tier |

### Tag Value Conventions

**Environment values (standardize):**
- `Production` OR `production` (pick one)
- `Staging` OR `staging`
- `Development` OR `development`

**Boolean values:**
- `true` / `false` (not `yes`/`no`, `1`/`0`)

**Date values:**
- ISO 8601: `2026-05-19` (not `05/19/2026`)

## Character Constraints Matrix

| System | Max Length | Valid Characters | Must Start With | Case |
|---|---|---|---|---|
| Kubernetes (label) | 63 | `[a-z0-9-]` | `[a-z]` | lowercase |
| Kubernetes (subdomain) | 253 | `[a-z0-9.-]` | `[a-z0-9]` | lowercase |
| Docker (repository) | 255 | `[a-z0-9._-]` | `[a-z0-9]` | lowercase |
| Docker (tag) | 128 | `[a-zA-Z0-9._-]` | `[a-zA-Z0-9]` | mixed |
| Ansible (role) | No limit | `[a-z0-9_]` | `[a-z]` | lowercase |
| Ansible (variable) | No limit | `[a-z0-9_]` | `[a-z_]` | lowercase |
| NetBox (slug) | No hard limit | `[a-z0-9-]` | `[a-z0-9]` | lowercase |
| AWS (S3 bucket) | 3-63 | `[a-z0-9-]` | `[a-z0-9]` | lowercase |
| AWS (tag key) | 128 | `[a-zA-Z0-9 +=._:/@-]` | Any | mixed |

## Common Anti-Patterns to Avoid

### 1. Mixing Case Inconsistently

❌ `MyApp`, `myapp`, `MYAPP` across systems

✅ Pick one: `myapp` everywhere

### 2. Encoding Too Much in Names

❌ `prod-us-east-1-web-frontend-v1-public-blue-t3-large`

✅ Name: `frontend-app`, Tags: `{environment: prod, version: 1, instance: blue}`

### 3. Using Forbidden Characters

❌ `my_app` in Kubernetes (underscores)

❌ `my-role` in Ansible (hyphens)

✅ Check character constraints for your system

### 4. Starting/Ending with Separators

❌ `-myapp`, `myapp-`, `_myapp`

✅ `myapp`, `my-app`

### 5. Very Long Names

❌ `my-application-that-processes-customer-orders-from-the-web-frontend`

✅ `order-processor`

### 6. Inconsistent Environment Names

❌ `prod`, `production`, `PROD`, `Prod` in different places

✅ Pick one: `prod` everywhere

### 7. Non-Sortable Numbering

❌ `app-1`, `app-10`, `app-2` (sorts as 1, 10, 2)

✅ `app-01`, `app-02`, `app-10` (sorts correctly)

## Decision Trees

### Choosing Delimiters

```
Is this a code identifier? (variable, role name, Python module)
├─ Yes → Use underscores: my_role_name
└─ No → Is DNS compliance required? (Kubernetes, Docker, domains)
   ├─ Yes → Use hyphens: my-resource-name
   └─ No → Organizational choice, but hyphens are universal default
```

### Choosing Case

```
Does the system REQUIRE lowercase? (Kubernetes, Docker repos, DNS)
├─ Yes → Use lowercase
└─ No → Does the system PREFER lowercase? (NetBox slugs, Ansible)
   ├─ Yes → Use lowercase unless specific exception (proper names)
   └─ No → Pick lowercase for consistency anyway (tag values, etc.)
```

### Choosing Name Length

```
Will this appear in logs, CLIs, or UIs frequently?
├─ Yes → Short (1-3 words): web-frontend
└─ No → Is it primarily for humans? (documentation, display names)
   ├─ Yes → Descriptive but concise: "Frontend Web Application"
   └─ No → Is it machine-generated? (UUIDs, commit SHAs)
      └─ Yes → Any length, but consider truncation limits
```

## Quick Reference: Naming by Resource Type

### Servers/VMs

**Pattern:** `<environment>-<function>-<instance>`

**Examples:** `prod-web-01`, `staging-database-primary`

### Containers

**Pattern:** `<app>-<component>`

**Examples:** `myapp-frontend`, `myapp-backend:1.2.3`

### Kubernetes Resources

**Pattern:** `<app>-<component>-<resource-type>`

**Examples:** `myapp-frontend-deployment`, `myapp-backend-service`

### Ansible Roles

**Pattern:** `<capability>` or `<component>_<subcomponent>`

**Examples:** `docker`, `ipam_netbox`, `hyperv_networking`

### Terraform Modules

**Pattern:** `terraform-<provider>-<resource>`

**Examples:** `terraform-aws-vpc`, `terraform-google-gke`

### Cloud Resources

**Pattern:** `<org>-<environment>-<purpose>`

**Examples:** `acme-prod-logs`, `acme-staging-backups`

## Summary: The Universal Naming Recipe

1. **Lowercase** by default
2. **Hyphens** for names, **underscores** for code
3. **Short** (1-3 words) for most uses
4. **Structured** by directories/namespaces, not encoded in names
5. **Consistent** across your organization
6. **Tagged** with metadata, not embedded in the name
7. **DNS-safe** when exposed externally
8. **Sortable** when using numbers (use leading zeros)

**Formula:** `<function>-<qualifier>-<instance>`

**Examples:**
- `web-frontend-01`
- `api-gateway`
- `database-primary`
- `cache-redis`
