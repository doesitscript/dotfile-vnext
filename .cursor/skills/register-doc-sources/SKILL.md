---
name: register-doc-sources
description: Registers remote documentation URLs in project-level .cursor/config.json and processes them for active use. Use when the user provides doc sources, asks to add/index docs, or requests @doc handles with suggested titles.
---

# Register Doc Sources

## Purpose
Add user-provided remote docs into project-level Cursor docs config in a repeatable way, with clean names and immediate processing.

## When To Use
- User says things like: "here are N doc sources", "add these to Cursor docs", "index these docs", "make these available as @doc".
- User wants suggested titles/handles for raw URLs.

## Inputs Expected
- A list of doc URLs.
- Optional explicit names/titles. If missing, generate names.

## Required Workflow
1. Read `<project-root>/.cursor/config.json`.
2. If missing, create it with:
   - a top-level object
   - `docs` array
3. Build one object per source:
   - `name`: doc handle
   - `url`: source URL
4. Merge without deleting existing entries:
   - keep existing docs
   - add new docs
   - dedupe by URL (first existing wins unless user asked to replace)
5. Write valid JSON back to `.cursor/config.json`.
6. Confirm what was added and how each URL maps to `@doc <name>`.
7. Process the URLs immediately by fetching/reading them so they are active reference context for the current task.

## Name Suggestion Rules
Use lowercase kebab-case and keep names short but specific.

Priority order:
1. If user gives a preferred name, use it.
2. Else infer from URL path and page topic.
3. Prefix with domain/topic when needed to avoid collisions.

Recommended transformations:
- Strip protocol and query params.
- Convert separators to `-`.
- Remove stopwords like `the`, `and`, `guide` only if name stays clear.
- Keep key topic words: `inventory`, `precedence`, `roles`, `yaml`, `builtin`.

Examples:
- `https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html`
  -> `ansible-inventory-guide`
- `https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html`
  -> `ansible-general-precedence`

## Output Format To User
- Report the config path updated.
- List all added mappings:
  - `@doc <name>` -> `<url>`
- State that docs were processed for the current run.

## Safety Rules
- Do not remove unrelated existing docs unless user explicitly asks.
- Do not rename existing entries unless user asks.
- Preserve JSON validity.
