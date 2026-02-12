# Register Doc Sources - Example

This example shows the exact workflow used in this project to register Ansible documentation as Cursor doc sources.

## Example Request

```text
Here are 8 doc sources. Add them to project Cursor docs, suggest names, process them, and map them to @doc handles.
```

## Source List (from current instructions)

```markdown
- { "name": "ansible-inventory-guide", "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html" }
- { "name": "ansible-host-group-vars", "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#splitting-out-vars" }
- { "name": "ansible-var-merge", "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#how-we-merge" }
- { "name": "ansible-variable-precedence", "url": "https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html" }
- { "name": "ansible-general-precedence", "url": "https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html" }
- { "name": "ansible-roles", "url": "https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html" }
- { "name": "ansible-yaml-syntax", "url": "https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html" }
- { "name": "ansible-builtin-collection", "url": "https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html" }
```

## Snippet: Existing Instruction Block

```markdown
### 4. The Ansible "Best Practices" Guide

Use the same structure and behavior demonstrated in the standard remote-doc example:

{
  "docs": [
    {
      "name": "my-wiki",
      "url": "https://raw.githubusercontent.com/myorg/myrepo/main/docs/overview.md"
    }
  ]
}

For each entry below, create a corresponding object inside the "docs" array of .cursor/config.json.
...
Processing requirements:
1. Cursor must fetch and index each remote URL so the content becomes available for retrieval.
2. Cursor must expose each document via its assigned @doc handle (e.g., @doc ansible-inventory-guide).
```

Source: `instructions.md`

## Snippet: Result Written To Project Config

```json
{
  "docs": [
    {
      "name": "ansible-inventory-guide",
      "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html"
    },
    {
      "name": "ansible-host-group-vars",
      "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#splitting-out-vars"
    },
    {
      "name": "ansible-var-merge",
      "url": "https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#how-we-merge"
    }
  ]
}
```

Source: `.cursor/config.json` (truncated for brevity)

## Reuse Prompt Template

```text
Use register-doc-sources.
Add these doc URLs to .cursor/config.json, suggest clean kebab-case names, preserve existing docs, dedupe by URL, and process the URLs immediately for current-run context.
URLs:
- <url-1>
- <url-2>
- <url-3>
```

## Expected Output Shape

- Updated file path: `.cursor/config.json`
- Added mappings:
  - `@doc <name>` -> `<url>`
- Confirmation that URLs were processed for current session context
