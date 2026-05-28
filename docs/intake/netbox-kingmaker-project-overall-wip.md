# NetBox Must Become an Enforced Runtime Dependency, Not Documentation

The current failure mode is not a tooling problem. It is a governance enforcement problem.

Right now NetBox exists in:

* narrative
* plans
* seed files
* repo structure
* intentions
* AGENTS.md language
* architectural philosophy

But it does NOT exist as:

* a hard runtime dependency
* a promotion gate
* a required execution artifact
* a verification authority
* a mandatory precondition
* a blocking system-of-record contract

That means engineers and AI agents can still successfully complete work while bypassing live NetBox state.

That is the root issue.

The solution is not “more reminders.”
The solution is making bypass physically impossible inside the workflow.

---

# Core Principle

NetBox is not documentation.

NetBox is:

* inventory authority
* topology authority
* IPAM authority
* DNS intent authority
* service ownership authority
* ingress authority
* environment authority
* deployment eligibility authority

If something exists operationally and is absent from NetBox:

* it does not exist
* deployment should fail
* promotion should fail
* plan validation should fail
* merge should fail

You must structurally force this behavior.

---

# The Actual Architectural Problem

Your project currently treats:

* diagrams as enforceable
* Terraform as enforceable
* inventories as enforceable
* linting as enforceable
* CI as enforceable

But NetBox is treated as:

* metadata
* advisory
* late-stage reconciliation
* optional synchronization

That is why every AI drifts away from it.

AI follows:

1. blocking systems
2. executable systems
3. validated systems
4. required systems

AI ignores:

* philosophy
* aspirational governance
* “remember to”
* “first-class citizen”
* comments
* narrative architecture

If NetBox is not in the execution graph:
it will always decay.

---

# What Must Change

# 1. NetBox Must Become a Required Runtime Slice

You already have:

* Required Diagram Checklist

You need:

* Required NetBox Slice

No plan may exist without it.

Every plan MUST contain:

```markdown
# Required NetBox Slice

## Objects Affected
- devices
- vm's
- interfaces
- ip addresses
- prefixes
- VLANs
- services
- DNS names
- tags
- tenants
- clusters
- virtual chassis
- load balancer VIPs
- ingress endpoints

## NetBox Impact
Describe:
- what will be created
- what will be modified
- what will be deprecated
- what will be reconciled

## Source of Truth Classification
- authoritative in NetBox
- authoritative in Terraform
- authoritative in Ansible
- derived from runtime discovery

## Apply Method
- direct API
- pynetbox
- netbox.netbox collection
- Terraform provider
- generated manifest

## Verification Receipts Required
- object lookup
- API verification
- diff verification
- screenshot optional
- reconciliation receipt mandatory

## Promotion Gate
Plan cannot progress until:
- live API apply completed
- verification completed
- receipts attached
```

---

# 2. NetBox Must Become a Promotion Gate

Right now:
“NetBox later”
still allows success.

That must end.

You need hard gates.

Example:

```text
Phase blocked:
- NetBox object missing
- interface missing
- service missing
- IP missing
- ingress endpoint missing
- ownership missing
- environment tag missing
```

Promotion must fail automatically.

Not “warn.”
Fail.

---

# 3. NetBox Must Exist Before Infrastructure

Current anti-pattern:

1. infra created
2. runtime works
3. NetBox updated later

Correct pattern:

1. intent created in NetBox
2. identifiers allocated
3. infra consumes NetBox
4. runtime verified against NetBox

NetBox must become:
PRE-RUNTIME INTENT AUTHORITY

Not post-runtime documentation.

---

# 4. Stop Seeding Defaults That Never Touch Live API

This is one of the biggest hidden failures.

You currently allow:

* defaults/
* vars/
* YAML manifests
* generated inventory
* “seed” structures

to masquerade as completed integration.

This creates fake completion.

You must distinguish:

```text
Declared State
≠
Applied State
≠
Verified State
```

Every workflow needs all 3 explicitly.

Example:

```text
Declared:
roles/ipam_netbox/defaults/main.yaml

Applied:
NetBox API transaction completed

Verified:
GET request confirms object exists
```

Without all three:
work is incomplete.

---

# 5. NetBox Apply Receipts Must Be Mandatory Artifacts

Every operational workflow should emit receipts.

Examples:

```text
artifacts/netbox/
  2026-05-27/
    ingress_apply.json
    vm_apply.json
    ipam_apply.json
    verification.json
```

AI agents should be required to attach:

* API payloads
* object IDs
* verification responses
* reconciliation outputs

This prevents “thought it was done.”

---

# 6. Introduce NetBox Reconciliation as a First-Class CI Phase

You need:

```text
make reconcile-netbox
```

or:

```text
ansible-playbook playbooks/reconcile_netbox.yaml
```

This must:

* compare live infra vs NetBox
* compare DNS vs NetBox
* compare inventory vs NetBox
* compare Hyper-V vs NetBox
* compare Kubernetes ingress vs NetBox
* compare Traefik routes vs NetBox

And fail if drift exists.

NetBox must continuously assert authority.

---

# 7. Install the Actual NetBox Integration Tooling

Yes — you are likely missing the “hard integration” layer.

You should absolutely install and standardize around these:

## Ansible Collection

Use:
`netbox.netbox`

This is mandatory.

Install:

```bash
ansible-galaxy collection install netbox.netbox
```

This gives:

* device management
* VM management
* interfaces
* IPAM
* cables
* services
* VLANs
* prefixes
* tags
* manufacturers
* tenants
* virtualization
* clusters

Without this:
your Ansible repo is treating NetBox as external instead of native.

That is a major architectural mistake.

---

# 8. Use pynetbox for Higher-Level Governance

Install:

```bash
pip install pynetbox
```

Use this for:

* reconciliation
* validation
* topology enforcement
* governance checks
* object dependency graphs
* CI assertions
* intent validation

Ansible modules alone are not enough.

You need programmable authority enforcement.

---

# 9. NetBox Must Become the Inventory Root

You should strongly move toward:

```text
NetBox
→ generates inventory
→ generates topology
→ generates DNS intent
→ generates ingress intent
→ generates VM definitions
→ generates environment relationships
```

NOT:

```text
Ansible inventory
→ later synchronized to NetBox
```

That direction is backwards.

---

# 10. AI Governance Must Explicitly Prioritize NetBox Before Runtime Work

Your AI instructions likely say things like:

* integrate NetBox
* first-class citizen
* source of truth

That is insufficient.

You need explicit hard ordering rules.

Example:

```text
AI EXECUTION ORDER REQUIREMENTS

1. Determine NetBox objects affected
2. Validate object existence
3. Apply missing NetBox intent
4. Verify NetBox API state
5. Generate reconciliation receipt
6. Only then continue to infrastructure/runtime work
```

And:

```text
Work is considered FAILED if:
- runtime exists without NetBox representation
- NetBox reconciliation skipped
- API verification absent
- receipts absent
```

AI needs binary enforcement language.

Not philosophy.

---

# 11. Introduce “NetBox Coverage” as a Measurable Metric

You need measurable governance.

Examples:

```text
NetBox Coverage:
- 97% VM coverage
- 100% ingress coverage
- 91% interface coverage
- 100% IP allocation coverage
- 72% service mapping coverage
```

If it is not measurable:
it will decay.

---

# 12. Introduce a NetBox Authority Matrix

Every object type must define authority.

Example:

| Object                  | Authority                       |
| ----------------------- | ------------------------------- |
| IP Prefixes             | NetBox                          |
| VLANs                   | NetBox                          |
| Device inventory        | NetBox                          |
| VM runtime state        | Hyper-V                         |
| Container runtime state | Kubernetes                      |
| DNS records             | Derived                         |
| Ingress routes          | NetBox intent + Traefik runtime |
| Terraform state         | Terraform                       |
| Kubernetes services     | Cluster runtime                 |
| Ownership metadata      | NetBox                          |

Without this:
systems compete for truth.

---

# 13. Remove the Word “Optional” Everywhere

This matters more than you think.

AI interprets:

* optional
* recommended
* later
* advisory
* reconcile eventually

as:
“safe to skip.”

You must use:

* REQUIRED
* BLOCKING
* PROMOTION GATE
* MUST VERIFY
* FAIL IF ABSENT

---

# 14. NetBox Should Own Ingress Metadata

Your Traefik issue reveals a deeper problem.

Ingress was treated as:
runtime networking.

It should be:
topology authority.

NetBox should own:

* service exposure intent
* VIP ownership
* ingress ownership
* DNS intent
* public/private classification
* TLS ownership
* environment exposure
* external dependencies

Traefik should consume intent.
Not define it.

---

# 15. Recommended Final Structural Pattern

The mature architecture looks like this:

```text
NetBox
    ↓
Intent Layer
    ↓
Generated Infrastructure Metadata
    ↓
Terraform / Ansible / Kubernetes
    ↓
Runtime
    ↓
Reconciliation
    ↓
NetBox Verification
    ↓
Promotion
```

NOT:

```text
Terraform/Ansible
    ↓
Runtime
    ↓
Maybe NetBox Later
```

---

# Final Reality Check

Your project does not currently have a NetBox integration problem.

It has:

* an authority enforcement problem
* a workflow ordering problem
* a promotion gate problem
* a runtime contract problem

The evidence is simple:

People and AI can successfully complete work while bypassing NetBox.

As long as that remains true:
NetBox is not actually integrated.

It is decorative governance.

That is all.
