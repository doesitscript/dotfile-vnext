# ps_apply_help_template

Task: Add standard PowerShell comment-based help + align script with repo conventions.

## Inputs
- Target script path
- Optional behavior notes or use cases

## Workflow
1) Read `.cursor/templates/powershell_help_template.ps1`.
2) Insert the help block at the top of the target script.
3) Ensure the `param()` block follows immediately after help (or after required `#requires` lines).
4) Populate fields based on actual script behavior.
5) Validate that `.PARAMETER` entries match `param()` exactly (names, types, defaults).
6) Add at least 2 real examples (or 3 for tool-style scripts).
7) Ensure Get-Help renders cleanly.

## Rules
- Use PowerShell comment-based help at the very top of the script (the `<# ... #>` help block).
- Do not invent custom headers or wrapper frameworks.
- Keep help accurate to what the script actually does.
- Ensure parameter docs match the actual `param()` block exactly (names, types, defaults).
- Include `.NOTES` with: Idempotency, Destructive behavior, Assumptions, Safety, and Logging/Error behavior summary.
- Do not print secrets. In examples, use placeholders.

## Tool-like utility requirements
If script is intended to behave like a utility tool:
- parameters via `param()`
- prints human-facing results with `Write-Host`
- uses `Write-Verbose` for diagnostics
- throws for unrecoverable errors
- return `0` on success and non-zero on failure (top-level catch sets exit code)
- support `-WhatIf` if mutating anything (`SupportsShouldProcess`)

### Recommended pattern for mutating scripts
```powershell
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Force
)
```

```powershell
if ($PSCmdlet.ShouldProcess("Target[$target]", "Action[$action]")) {
    # do it
}
```

## Validation checklist
- `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES` present
- examples use valid invocation syntax
- parameter docs and `param()` are fully aligned
- no secret values are printed
