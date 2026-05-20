# Community Naming Examples

## Source

- Kubernetes Community: https://github.com/kubernetes/community
- Cloud Posse Examples: https://github.com/cloudposse/examples
- Gruntwork Infrastructure Live Example: https://github.com/gruntwork-io/terragrunt-infrastructure-live-example

## Purpose

Real-world naming patterns from widely-adopted projects, showing how mature communities solve naming at scale.

## Kubernetes Community Patterns

### Repository Naming

**Pattern:** `<purpose>-<component>`

Examples from kubernetes org:
- `kubernetes/kubernetes` — Core project
- `kubernetes/website` — Documentation site
- `kubernetes/community` — Community governance
- `kubernetes/enhancements` — KEP (enhancement proposal) tracking
- `kubernetes-sigs/cluster-api` — SIG-specific projects

### SIG (Special Interest Group) Naming

**Pattern:** `<ecosystem>-sig-<topic>`

Examples:
- `kubernetes-sigs/` — Kubernetes SIGs prefix
- Topics: `cluster-api`, `controller-runtime`, `kustomize`

### Resource Naming in Examples

From Kubernetes examples and documentation:

**Deployments:**
```yaml
name: nginx-deployment
name: my-app-deployment
name: frontend
```

**Services:**
```yaml
name: nginx-service
name: my-app-service
name: backend-api
```

**Namespaces:**
```yaml
name: production
name: development
name: team-platform
```

### Label Patterns

```yaml
metadata:
  labels:
    app: nginx
    tier: frontend
    environment: production
```

### Multi-Tenant Pattern

```yaml
metadata:
  name: app-tenant-a
  namespace: tenant-a
  labels:
    app: myapp
    tenant: tenant-a
```

## Cloud Posse Patterns

### Module Naming

**Pattern:** `terraform-<provider>-<resource>`

Examples:
- `terraform-aws-vpc`
- `terraform-aws-eks-cluster`
- `terraform-google-gke-cluster`
- `terraform-null-label`

### Stack Naming

From Cloud Posse stacks:

```
<namespace>-<environment>-<stage>-<name>
```

Examples:
- `eg-ue1-prod-vpc`
- `eg-ue1-prod-eks-blue`
- `eg-gbl-prod-iam`

### Component Naming in Stacks

```
stacks/
└── orgs/
    └── acme/
        ├── _defaults.yaml
        └── plat/
            ├── dev/
            │   ├── us-east-1/
            │   │   ├── vpc.yaml
            │   │   └── eks.yaml
            │   └── us-west-2/
            └── prod/
                ├── us-east-1/
                └── us-west-2/
```

### Tag Patterns

```yaml
tags:
  Name: eg-ue1-prod-vpc
  Namespace: eg
  Environment: ue1
  Stage: prod
  ManagedBy: Terraform
  Repository: infrastructure
```

## Gruntwork Infrastructure Live

### Directory Structure at Scale

```
infrastructure-live/
├── _global/
│   ├── route53/
│   └── iam/
├── prod/
│   ├── account.hcl
│   ├── us-east-1/
│   │   ├── region.hcl
│   │   ├── networking/
│   │   │   ├── vpc/
│   │   │   ├── alb/
│   │   │   └── route53/
│   │   ├── services/
│   │   │   ├── frontend-app/
│   │   │   ├── backend-api/
│   │   │   └── worker-service/
│   │   └── data-stores/
│   │       ├── mysql/
│   │       ├── postgres/
│   │       └── redis/
│   └── us-west-2/
│       └── (same structure)
├── stage/
│   └── (same as prod)
└── dev/
    └── (same as prod)
```

### Service Naming Pattern

**Pattern:** `<function>-<type>`

Examples:
- `frontend-app`
- `backend-api`
- `worker-service`
- `admin-ui`
- `data-processor`

### Data Store Naming

**Pattern:** `<database-type>-<role>`

Examples:
- `mysql-primary`
- `postgres-analytics`
- `redis-cache`
- `elasticsearch-logs`

### Multi-Region Pattern

Same component in multiple regions:

```
prod/us-east-1/services/frontend-app/
prod/us-west-2/services/frontend-app/
prod/eu-west-1/services/frontend-app/
```

Each has independent:
- `terragrunt.hcl` with region-specific inputs
- Terraform state
- Deployed resources

## Scaling Patterns (10 → 100 → 1000 Resources)

### 10 Resources

**Simple flat structure:**
```
prod/
├── vpc/
├── app-1/
├── app-2/
└── database/
```

### 100 Resources

**Introduce categories and regions:**
```
prod/
├── us-east-1/
│   ├── networking/
│   ├── services/ (10-20 apps)
│   └── data-storage/
└── us-west-2/
    └── (same)
```

### 1000 Resources

**Multi-account, multi-region, deep categorization:**
```
accounts/
├── prod-primary/
│   ├── global/
│   └── regional/
│       ├── us-east-1/
│       │   ├── networking/
│       │   ├── compute/
│       │   │   ├── ecs/ (50+ services)
│       │   │   ├── eks/
│       │   │   └── lambda/
│       │   ├── data-storage/
│       │   │   ├── rds/ (20+ databases)
│       │   │   ├── dynamodb/
│       │   │   └── s3/
│       │   └── security/
│       └── us-west-2/
├── prod-dr/
├── staging/
└── dev/
```

## Multi-Tenant Patterns

### Namespace-Based (Kubernetes)

```
namespaces/
├── tenant-a/
├── tenant-b/
└── tenant-c/
```

Each tenant gets:
- Dedicated namespace
- Resource quotas
- Network policies
- RBAC bindings

### Account-Based (AWS)

```
accounts/
├── customer-a-prod/
├── customer-a-staging/
├── customer-b-prod/
└── customer-b-staging/
```

Each customer gets:
- Dedicated AWS account
- Separate billing
- Hard resource isolation

### Tag-Based (Mixed)

```yaml
tags:
  Tenant: customer-a
  Environment: production
  BillingCode: ABC-123
```

Resources across shared infrastructure, segregated by tags.

## Environment Patterns

### Simple (3 Environments)

```
dev/
staging/
prod/
```

### Standard (4 Environments)

```
dev/
qa/
staging/
prod/
```

### Enterprise (Many Environments)

```
dev/
feature-branch-a/
feature-branch-b/
integration/
qa/
uat/
staging/
prod/
prod-dr/
```

### Blue/Green

```
prod-blue/
prod-green/
```

Alternate between blue and green for zero-downtime deployments.

## Service Mesh Patterns

### Istio

```yaml
apiVersion: v1
kind: Service
metadata:
  name: productpage
  labels:
    app: productpage
    service: productpage
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: productpage-v1
  labels:
    app: productpage
    version: v1
```

**Pattern:** Service name + version suffix

### Consul

```
service "web" {
  id   = "web-01"
  name = "web"
  tags = ["prod", "us-east-1"]
}
```

## GitOps Patterns

### FluxCD

```
clusters/
├── production/
│   ├── apps/
│   │   ├── app-a/
│   │   └── app-b/
│   └── infrastructure/
│       ├── ingress-nginx/
│       └── cert-manager/
└── staging/
    └── (same)
```

### ArgoCD

```
apps/
├── production/
│   ├── app-a.yaml
│   └── app-b.yaml
└── staging/
    ├── app-a.yaml
    └── app-b.yaml
```

## CI/CD Naming

### GitHub Actions Workflows

```
.github/workflows/
├── deploy-prod.yml
├── deploy-staging.yml
├── test.yml
└── lint.yml
```

### Jenkins Pipelines

```
pipelines/
├── prod-deploy-frontend/
├── prod-deploy-backend/
├── staging-deploy-all/
└── dev-deploy-all/
```

## Observability Patterns

### Prometheus Metrics

```
namespace_subsystem_metric
```

Examples:
- `http_requests_total`
- `process_cpu_seconds_total`
- `myapp_database_connections_active`

### Datadog Tags

```yaml
tags:
  - env:production
  - service:frontend
  - version:1.2.3
  - region:us-east-1
```

### CloudWatch Log Groups

```
/aws/lambda/prod-frontend-app
/aws/ecs/prod-backend-api
/aws/rds/prod-mysql-primary
```

## Key Takeaways from Community Examples

1. **Consistency wins** — Pick one pattern and apply it everywhere
2. **Hierarchy is directory-based** — Use folders, not names, for structure
3. **Short component names** — `vpc`, `eks`, `rds` not `virtual-private-cloud`
4. **Environment first, then region** — `prod/us-east-1/` not `us-east-1/prod/`
5. **Categories at scale** — Introduce `networking/`, `services/` when >20 resources
6. **Tags for metadata** — Use tags/labels for ownership, cost, automation
7. **Versioning in labels, not names** — `version: v1` tag, not `app-v1` name
8. **Separate names from identifiers** — Human name (`frontend-app`) vs system ID (UUID)

## References

- Kubernetes Community: https://github.com/kubernetes/community
- Kubernetes Examples: https://github.com/kubernetes/examples
- Cloud Posse Modules: https://github.com/cloudposse
- Cloud Posse Reference Architectures: https://docs.cloudposse.com/
- Gruntwork Examples: https://github.com/gruntwork-io
- Terraform AWS Modules: https://github.com/terraform-aws-modules
