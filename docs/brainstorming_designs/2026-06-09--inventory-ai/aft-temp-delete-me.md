# AFT Three-Tier Customizations and SSM Guide

Came from:
- `oneoffs/docs/plans/20260702-1455-aft-three-tier-customization-guide.md`

Preview status: staging for possible promotion to `ai-resource-library` (guide, not a day-2 invoke runbook).

## Overview

AFT applies customizations in three tiers at different points in the account lifecycle. Bread also uses SSM Parameter Store heavily for AFT framework config; account-level SSM patterns for customization data have been uneven historically.

Related runbooks:

- Invoke customizations at scale → library `aft-customizations-change-enablement-and-invoke-at-scale.md`
- Local plan/apply → [`runbook/aft-develop-customizations-locally.md`](./runbook/aft-develop-customizations-locally.md)
- Account tags → [`runbook/aft-account-request-tagging.md`](./runbook/aft-account-request-tagging.md)

## Tier model

```text
Account request (aft-account-request)
        |
        v
TIER 1  aft-account-provisioning-customizations
        Step Functions during create (pre Control Tower finish / early hooks)
        |
        v
        Control Tower account created
        |
        v
TIER 2  aft-global-customizations
        CodePipeline — baseline for all accounts
        |
        v
TIER 3  aft-account-customizations
        CodePipeline — shared package selected by account_customizations_name
```

| Tier | Repo | When it runs | Typical content |
|------|------|--------------|-----------------|
| 1 Provisioning | `aft-account-provisioning-customizations` | During provisioning (Step Functions) | Early IAM, metadata, custom ASL workflows |
| 2 Global | `aft-global-customizations` | After create, all accounts | Org baselines, security, shared helpers |
| 3 Account | `aft-account-customizations` | After global, for accounts pointing at a package | Role-family blueprints (SDLC apps, shared services, foundation, …) |

Customization packages under account customizations are selected via `account_customizations_name` on the account request (and reflected in DynamoDB metadata). See **Account customization packages** below.

## Account customization packages

### What a “package” is

In `aft-account-customizations`, each top-level folder (for example `sdlc-dev-customizations-wave0/` or `sharedservices-harness-customizations/`) is a **customization package**: one Terraform product that AFT runs for every account that points at that package name.

It is **not** “one folder per AWS account.” It is **one shared blueprint for a family of related accounts**.

When you vend or update an account in `aft-account-request`, you set `account_customizations_name` to that folder name. AFT then runs that package’s pipeline for that account (after global customizations). Many accounts can share the same package when they need the same class of landing-zone content.

Think of it as:

```text
aft-account-request
  account A  -->  account_customizations_name = "sdlc-dev-customizations-wave0"
  account B  -->  account_customizations_name = "sdlc-dev-customizations-wave0"
  account C  -->  account_customizations_name = "sharedservices-harness-customizations"

aft-account-customizations/
  sdlc-dev-customizations-wave0/     <-- one package, applied to A and B
  sharedservices-harness-customizations/  <-- different package, applied to C
```

### Why packages exist (related accounts, shared needs)

Accounts that play the **same role in the org** usually need the **same kinds of infrastructure**, even when they are different account IDs or different apps:

| Family | Why they cluster | Package idea |
|--------|------------------|--------------|
| **SDLC / application / service** | Host applications through the software lifecycle (dev → test → prod). Need app-friendly network, DNS, identity hooks, and deploy-time integrations | `sdlc-*-customizations*` |
| **Shared services** | Provide a platform capability many apps consume (Harness, image management, AD, general shared services) | `sharedservices-*-customizations*` |
| **Foundation / core** | Org control-plane style accounts (log archive, audit, CT management, network hub, KMS, …) | `foundation-*`, `log-archive-*`, `network-hub-*`, etc. |

Global customizations still run for **everyone**. Packages add the **role-specific** layer on top.

### Example: SDLC (application / service) accounts

**SDLC accounts** are the accounts where application and service teams actually run workloads across the delivery lifecycle (development, QA/SIT/UAT, production, and often wave-specific cohorts). They are related to each other because they share the same *class* of needs—even when each account belongs to a different product team.

Typical needs for that class (logical; your packages implement some or all of these):

| Need | Why an app/service account wants it |
|------|-------------------------------------|
| VPC / subnet layout suited to apps | Workloads, ALBs, private compute, multi-AZ |
| DNS / Route 53 (private zones, on-prem forwarders) | Service discovery, hybrid name resolution |
| Security groups / baseline network rules | Controlled ingress/egress for app tiers |
| IAM roles / instance profiles for compute | EC2, ECS, EKS, or pipeline runners assume roles |
| SSM / session / patch posture | Ops access and patching without bastion sprawl |
| Logging / monitoring hooks | Ship logs/metrics to central observability |
| Secrets / KMS usage patterns | App config and encryption aligned to org standards |
| CI/CD integration surfaces | Roles/trust for Harness, CodePipeline, GitHub OIDC, etc. |
| Environment differentiation | Dev looser / cheaper; prod tighter / HA / change-controlled |

Bread’s repo already reflects that clustering with packages such as:

- `sdlc-dev-customizations` / `sdlc-dev-customizations-wave0`
- `sdlc-qa-customizations-wave0`
- `sdlc-uat-customizations` / `sdlc-uat-customizations-wave0`
- `sdlc-prod-customizations-wave0`

**Wave** packages are still the same *idea* (SDLC/app landing zone), but a versioned or cohorted blueprint so you can roll the same class of changes in controlled batches.

Contrast with shared-services packages (same mechanism, different family):

- `sharedservices-general-customizations`
- `sharedservices-harness-customizations`
- `sharedservices-imagemanagement-customizations`

Those accounts are not “app SDLC” boxes; they are **platform capability** boxes. They still use a package folder so every Harness (or image-mgmt) account of that type stays consistent.

### How selection works day to day

1. Author Terraform under `aft-account-customizations/<package>/`
2. On the account request, set `account_customizations_name = "<package>"`
3. Confirm in DynamoDB metadata (`account_customizations_name`) if needed
4. After merge, invoke / CR so that package’s pipeline runs for the target accounts

Changing package **code** affects every account that points at that package when you next invoke. Changing which package an account uses is an **account-request** change (`account_customizations_name`), not a global-customizations change.

## Wiring in AFT platform config

Repos are named in the AFT module / upgrade-tools inputs (live pins belong in library canonical values). Pattern:

```hcl
global_customizations_repo_name                   = "Bread-Financial/aft-global-customizations"
account_customizations_repo_name                  = "Bread-Financial/aft-account-customizations"
account_provisioning_customizations_repo_name     = "Bread-Financial/aft-account-provisioning-customizations"
vcs_provider                                      = "github"
```

After platform deploy, framework SSM typically includes:

```text
/aft/config/global-customizations/repo-name
/aft/config/account-customizations/repo-name
/aft/config/account-provisioning-customizations/repo-name
/aft/config/terraform/version
/aft/config/terraform/distribution
```

Verify (AFT management account `474668427263`, `us-east-2`):

```bash
aws ssm get-parameter --name "/aft/config/terraform/version" --query "Parameter.Value" --output text
aws ssm get-parameter --name "/aft/config/global-customizations/repo-name" --query "Parameter.Value" --output text
```

## Two SSM categories (do not conflate)

### A — AFT framework parameters

Owned by the AFT platform. Pipelines and init scripts read them (Terraform version, repo names, backend pointers, feature flags). Changing these is a **platform / binary / module** concern, not a normal customization PR.

### B — Application / account data in SSM

Account customizations sometimes store VPC definitions and similar config in SSM and read them with `data.aws_ssm_parameter`. That path is powerful but:

- Sensitivity marks from the AWS provider can break `for_each` (see sensitive-values runbook)
- Drift between “SSM as source of truth” vs “Terraform-only” creates dual maintenance
- Historical Bread notes: SSM-for-customization-data was explored, partially adopted, then often abandoned in favor of repo-local Terraform

**Practical rule:** use Category A SSM for AFT framework config; prefer Git + Terraform for customization resources unless the team explicitly owns an SSM data contract.

## Where work belongs

| Change type | Put it in |
|-------------|-----------|
| New account / tags / OU / which package an account uses | `aft-account-request` |
| Org-wide baseline every account should get | `aft-global-customizations` |
| Shared blueprint for a related account family (SDLC apps, shared services, foundation, …) | `aft-account-customizations/<package>/` |
| Must run during create before pipelines | `aft-account-provisioning-customizations` |
| Re-run existing packages after merge | `aft-invoke-customizations` (change-enablement runbook) |

## Operator pitfalls

1. **Merging to `main` does not fan out** — use invoke / CR sequencing (see change-enablement runbook).
2. **Wrong tier** — putting account-specific VPC work in global customizations scales poorly and raises blast radius.
3. **Tagging in the wrong repo** — account request tags belong in `aft-account-request`, not global Terraform.
4. **Assuming SSM data is non-sensitive** — TF 1.x marks many SSM reads sensitive; that affects module outputs and `for_each`.

## Promotion note

When promoting to the library, keep this as a **guide** page next to operational runbooks; do not merge it into the invoke-at-scale page (different job: model vs execute).
