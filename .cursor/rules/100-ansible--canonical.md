# Ansible documentation: canonical references

When assisting with Ansible in this project, follow the behavior defined in `instructions.md` (lines 88–96).

## Behavior

1. **Automatic consultation**  
   Consult the relevant registered @doc sources for Ansible work without requiring the user to tag them manually. Use the docs listed in `.cursor/config.json` under the `docs` array (e.g. `ansible-inventory-guide`, `ansible-variable-precedence`, `ansible-roles`, `ansible-yaml-syntax`, `ansible-builtin-collection`, etc.).

2. **Explicit @doc references**  
   When the user references a document with `@doc <name>`, load and use that remote source in your reasoning.

3. **Alignment with docs**  
   When analyzing or generating Ansible code, inventories, roles, or variable structures, align recommendations with the authoritative behavior described in these registered documentation sources.

4. **Conflicts**  
   When the repository and the official documentation disagree, surface the discrepancy and explain the authoritative behavior from the registered docs.

5. **Canonical**  
   Treat these documentation sources as canonical references for all Ansible-related reasoning for the duration of the session.

## Registered Ansible doc names (from config)

Use these @doc handles when relevant: `ansible-core-index`, `ansible-developer-guide`, `ansible-collections`, `ansible-tips-tricks`, `ansible-inventory-guide`, `ansible-host-group-vars`, `ansible-var-merge`, `ansible-variable-precedence`, `ansible-general-precedence`, `ansible-roles`, `ansible-yaml-syntax`, `ansible-builtin-collection`.

## @doc Trigger Gates — BLOCKING

These are not advisory. The agent MUST NOT write, review, or propose any task, role,
or playbook until the @doc sources for the applicable condition have been fetched and
are in context. **STOP — fetch the required docs before producing any output.**

Do not wait for the user to reference them explicitly:

| Condition | @doc to fetch — REQUIRED before any output |
|---|---|
| Writing any task or role targeting Windows hosts | `ansible-windows-collection`, `community-windows-collection` |
| Designing role structure, deciding role placement, or role interface questions | `ansible-roles` |
| Inventory, group_vars, or host_vars questions | `ansible-inventory-guide`, `ansible-host-group-vars`, `ansible-var-merge` |
| Node categorization, environment distinction, "where does X belong", playbook targeting strategy, "which hosts get this role" | `ansible-inventory-guide`, `ansible-tips-tricks` — official docs explicitly address "when" groups (dev/test/prod) and function-based inventory targeting |
| Variable precedence, override, or scope questions | `ansible-variable-precedence`, `ansible-general-precedence` |
| YAML formatting or syntax questions | `ansible-yaml-syntax` |
| Module selection or built-in module use | `ansible-builtin-collection` |
| Collection design, FQCN, or namespace questions | `ansible-collections` |
| Best practice, tips, or idiomatic Ansible questions | `ansible-tips-tricks` |
| Developer guide, plugin, or module authoring | `ansible-developer-guide` |
| Any question where the answer relies on training recall, no project example exists, or the user asks for patterns/guidance/expertise | Fetch ALL relevant docs from `.cursor/config.json` before responding. Declare what was fetched. Do not answer from training alone. |
