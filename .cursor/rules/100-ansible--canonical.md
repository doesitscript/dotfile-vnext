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
