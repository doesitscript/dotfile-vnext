# PowerShell comment-based help contract

All PowerShell scripts in this repository must use standard PowerShell comment-based help.

Requirements:
- Use PowerShell comment-based help at the very top of the script (the `<# ... #>` help block).
- Do not invent custom headers or wrapper frameworks.
- Keep help accurate to what the script actually does.
- Ensure parameter docs match the actual `param()` block exactly (names, types, defaults).
- Add at least 2 examples that reflect real usage for the script.
- Include `.NOTES` with:
  - Idempotency
  - Destructive behavior
  - Assumptions
  - Safety
  - Logging/Error behavior summary
- Do not print secrets; use placeholders in examples.

Required help sections:
- `.SYNOPSIS`
- `.DESCRIPTION`
- `.PARAMETER` (for each parameter)
- `.EXAMPLE` (at least two)
- `.NOTES`

Behavioral alignment:
- If script behavior changes, update help in the same change.
- If a parameter is added, removed, renamed, or default changes, update `.PARAMETER` docs immediately.
- Keep changes minimal: only add/update help and small fixes required to make help truthful.
