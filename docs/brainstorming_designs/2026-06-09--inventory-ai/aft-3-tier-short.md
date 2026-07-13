# AFT Three-Tier Customizations and SSM Guide

Came from: `oneoffs` three-tier plan / import preview. This is a **placement guide**, not a day-2 invoke runbook.

## When to use

Decide **which repo / package** a change belongs in, and how SSM fits. For merge/CR/invoke steps use [change enablement](./aft-customizations-change-enablement-and-invoke-at-scale.md). For laptop plan use [develop locally](./aft-develop-customizations-locally.md). Broader architecture: [overview](./aft-overview-architecture-and-components.md).

## Background (just enough)

AFT customizations run in layers. Pushing git does not re-apply them to existing accounts — that needs invoke. Account customizations are **packages** (shared blueprints): many accounts can share one folder via `account_customizations_name`. That matches AWS’s folder = `account_customizations_name` model ([account customization options](../control_tower/aft-account-customization-options.full.md)).

```text
aft-account-request
        → Tier 1  aft-account-provisioning-customizations  (Step Functions at create)
        → Tier 2  aft-global-customizations               (all accounts)
        → Tier 3  aft-account-customizations/<package>    (selected package)
```

| Tier | Repo | When | Put here when… |
| --- | --- | --- | --- |
| 1 | `aft-account-provisioning-customizations` | During create | Must run before pipelines / early hooks |
| 2 | `aft-global-customizations` | After create, every account | Org-wide baseline |
| 3 | `aft-account-customizations/<package>/` | After global | Role-family blueprint (SDLC, shared services, foundation, …) |

Live wiring (repos, versions, flags): [canonical values](../control_tower_wip_collected/aft-upgrade-tools-canonical-values.md). Package list lives in the `aft-account-customizations` repo (re-list there; ~20 dirs at last collection).

## How to use this guide

### 1. Place the work

| Change | Where |
| --- | --- |
| New account / tags / OU / which package an account uses | `aft-account-request` |
| Everyone gets it | `aft-global-customizations` |
| A family of related accounts gets it | `aft-account-customizations/<package>/` |
| Must run during create | `aft-account-provisioning-customizations` |
| Re-run after merge | Invoke → [change enablement](./aft-customizations-change-enablement-and-invoke-at-scale.md) |

### 2. Understand packages (Tier 3)

```text
account request: account_customizations_name = "sdlc-dev-customizations-wave0"
                        ↓
aft-account-customizations/sdlc-dev-customizations-wave0/   ← one package, many accounts
```

- Changing **package code** affects every account pointing at that package on next invoke  
- Changing **which package** an account uses is an account-request change  

Examples of families: `sdlc-*-customizations*`, `sharedservices-*-customizations*`, foundation/network/log-archive style packages.

### 3. Do not conflate SSM types

| Category | What | Who changes it |
| --- | --- | --- |
| A — Framework | `/aft/config/...` (TF version, repo names, backends, feature flags) | Platform / binary / module runbooks |
| B — App data | Account customizations reading SSM for VPC/config | Prefer Git+Terraform unless the team owns an SSM data contract |

Framework SSM is **not** a normal customization PR. Live framework pins: [canonical values](../control_tower_wip_collected/aft-upgrade-tools-canonical-values.md).

### 4. Common pitfalls

1. Merge without invoke → nothing fans out  
2. Account-specific work in global → huge blast radius  
3. Tags in the wrong repo → belong in `aft-account-request`  
4. Platform flag `aft_feature_delete_default_vpcs_enabled` ≠ member-account VPC cleanup → [remediation](./aft-remediation-default-vpcs-non-governed-regions.md)

## Related

- [Change enablement](./aft-customizations-change-enablement-and-invoke-at-scale.md)
- [Develop locally](./aft-develop-customizations-locally.md)
- [Overview](./aft-overview-architecture-and-components.md)
- [Canonical values](../control_tower_wip_collected/aft-upgrade-tools-canonical-values.md)
