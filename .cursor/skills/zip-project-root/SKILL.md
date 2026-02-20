---
name: zip-project-root
description: Creates a zip archive from the project root while excluding .git and downloaded dependency/source folders. Use when the user asks to zip a project without git metadata or dependencies, including short trigger prompts like zipprojectroot, @zipprojectroot, archiveproject, or run zipprojectroot.
---

# Zip Project Root

## Purpose
Create a zip archive in the project root that excludes repository metadata and downloaded dependencies/sources.

## Trigger Phrases
Treat these short prompts as direct requests to run this skill:
- `zipprojectroot`
- `@zipprojectroot`
- `archiveproject`
- `run zipprojectroot`

## Instructions
1. Set the archive path to `<project-root>/<project-folder-name>.zip`.
2. If the zip already exists, delete it first.
3. Recursively collect files from the project root.
4. Exclude any file under these directories (at project root or anywhere nested):
   - `.git`
   - `node_modules`
   - `.venv`
   - `venv`
   - `vendor`
   - `dependencies`
   - `sources`
   - `downloaded`
   - `downloads`
5. **Critical for zip on macOS/Unix:** Paths in the archive are relative to the project root. You must exclude both root-level and nested paths. A pattern like `*/.venv/*` matches only `something/.venv/...`, not `.venv/...` at the root. Always include root-level patterns (e.g. `.venv/*`, `.git/*`) as well as nested ones (e.g. `*/.venv/*`, `*/.git/*`) so that root-level directories are excluded. On macOS/Unix, use the zip command template below.
6. Create the zip with optimal compression.
7. Return the full archive path to the user.

## zip (macOS / Unix)
Run from project root. Exclude both root-level and nested dirs so `.venv` and `.git` at root are not included:

```bash
zip -r -q "<project-root>/<project-folder-name>.zip" . \
  -x ".git/*" -x "*/.git/*" \
  -x ".venv/*" -x "*/.venv/*" \
  -x "venv/*" -x "*/venv/*" \
  -x "node_modules/*" -x "*/node_modules/*" \
  -x "vendor/*" -x "*/vendor/*" \
  -x "dependencies/*" -x "*/dependencies/*" \
  -x "sources/*" -x "*/sources/*" \
  -x "downloaded/*" -x "*/downloaded/*" \
  -x "downloads/*" -x "*/downloads/*"
```

## PowerShell Command Template
```powershell
$root = "<absolute-project-root>"
$projectName = Split-Path $root -Leaf
$zip = Join-Path $root "$projectName.zip"

if (Test-Path $zip) { Remove-Item $zip -Force }

$excludeDirs = @(
  '.git', 'node_modules', '.venv', 'venv', 'vendor',
  'dependencies', 'sources', 'downloaded', 'downloads'
)

$files = Get-ChildItem -Path $root -Recurse -File | Where-Object {
  $full = $_.FullName
  -not ($excludeDirs | ForEach-Object { $full -like "*\$_\*" } | Where-Object { $_ })
}

Compress-Archive -Path $files.FullName -DestinationPath $zip -CompressionLevel Optimal
Write-Output "Created: $zip"
```

## Example
For `D:\develop\dotfile-vnext`, output zip should be:
`D:\develop\dotfile-vnext\dotfile-vnext.zip`
