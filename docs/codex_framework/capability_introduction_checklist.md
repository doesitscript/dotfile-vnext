# Capability Introduction Checklist

Use this checklist when adding a **new Ansible capability** (role, playbook surface,
inventory registry, or exposure layer). Agents must complete it **before** writing
runtime inventory values or claiming the slice is done.

## Authority layering

| Layer | Location | Contains |
|-------|----------|----------|
| Patterns | `docs/reference/naming-standards/ansible.yml`, `render-patterns.yml`, `netbox.yml` | Reusable naming rules |
| Reference instances | `docs/reference/naming-standards/live-object-registry.yml` | This homelab's concrete names |
| Runtime desired state | `inventory/`, `roles/`, playbooks | Mirrors registry; never invents names |

**Do not** duplicate registry YAML in plan files or role defaults as the naming SSOT.

## Checklist (ordered)

1. **Classify the capability** — host role, service exposure, controller-local, router operator, etc.
2. **Check existing registry** — `live-object-registry.yml`, `resource-roles.yml`, active seeds.
3. **Add or extend patterns** in `ansible.yml` / `netbox.yml` / `render-patterns.yml` when the capability introduces a new naming surface (route keys, portproxy names, tags, custom fields).
4. **Add reference instances** in `live-object-registry.yml` — values derived from **deployed_by_role** and **service_code**, not generic placeholders (`app1`, `http-proxy`).
5. **Write role/playbook** — `role_name_*` vars, `argument_specs.yml`, README with Apply/Verify/Undo.
6. **Mirror inventory** — group_vars/host_vars match registry instances field-for-field.
7. **NetBox alignment** — seeds, tags, custom fields, consistency gate when services are modeled.
8. **Diagnostics / lessons** — when a vendor UI or product rule blocks operator config, document before the user assumes misconfiguration.
9. **Promoted plan** — `docs/plans/YYYY-MM-DD--slug/README.md` unless change is
   trivial; inherit implementation scope from intake blueprint unless
   `scope: doc-only`. The promoted plan must pass `docs/plans/README.md`
   Required Diagram Checklist and include the Diagram gate receipt in
   `framework-partner-process.mdc` even when Ansible code landed first.
10. **Live apply when execute is approved** — after repo artifacts exist, run
    preview/read-only verification with evidence, then apply `present` (or
    document explicit user deferral or prerequisite failure with probe output).
    **PROHIBITED:** labeling execute-complete while only `state: absent` when the
    user approved execute.
11. **Plan verification receipt** — on execute or slice complete, maintain
    `## Plan verification receipt` per
    [plan-verification-receipt.md](plan-verification-receipt.md) (full obligation
    inventory, not checklist-only).
12. **Enable-when-built (host_vars)** — when the user commissions a capability,
    set target host gates to `present` / `*_enabled: true` unless opted out or
    upstream prerequisite missing (document in role README). Plans ≠ Ansible;
    see AGENTS.md §18.

## Anti-patterns

- Generic route or portproxy names without a pattern row
- Inventory-first naming (writing `k3s_cluster.yaml` before schema)
- Plan bodies with full SSOT YAML dumps
- Recommending Merlin/custom firmware without model support check
- Doc-only promoted plan when intake blueprint already specifies roles and playbooks
- Status-only plan packet without Required Diagram Checklist and gate receipt
- Calling Traefik/router exposure "operator-controlled" when the user approved
  execute and no explicit deferral or failed prerequisite was recorded
- Checklist-only verification receipts while change-contract Verify or reference
  SSOT rows were never checked

## Related rules

- `framework-knowledge-and-research.mdc` — Naming Schema Research Gate, schema-before-inventory
- `framework-netbox-modeling.mdc`
- `framework-partner-process.mdc` — plan promotion, multi-plan execution
- `AGENTS.md` — Repo Truths (NetBox + naming schema)
