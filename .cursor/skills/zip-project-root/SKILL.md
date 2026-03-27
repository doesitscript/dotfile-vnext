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
   - `.git` — repo metadata (root and any nested sub-repos)
   - `node_modules` — npm dependencies
   - `.venv` — Python virtual environment
   - `.venv-win` — Windows Python virtual environment
   - `venv` — alternate Python venv name
   - `vendor` — vendored dependencies
   - `dependencies` / `sources` / `downloaded` / `downloads` — downloaded content
   - `roles/galaxy` — downloaded Ansible Galaxy roles (gitignored)
   - `collections/ansible_collections` — downloaded Ansible collections (gitignored)
   - `.facts_cache` — Ansible fact cache (gitignored)
   - `.ansible` — Ansible runtime directory (gitignored)
   - `.direnv` — direnv cache (gitignored)
5. **Critical for zip on macOS/Unix:** Paths in the archive are relative to the project root. The zip `-x` wildcard `*` does NOT match `/` in fnmatch, so `*/.git/*` only matches one level deep. Always include:
   - root-level patterns (e.g. `.venv/*`, `.git/*`)
   - one-level-deep nested patterns (e.g. `*/.venv/*`, `*/.git/*`)
   - two-level-deep nested patterns (e.g. `*/*/.git/*`) for sub-repos cloned inside the project
   On macOS/Unix, use the zip command template below.
6. Create the zip with optimal compression.
7. Return the full archive path to the user.

## zip (macOS / Unix)
Run from project root. Exclude root-level, one-level-deep, and two-level-deep nested dirs.
The two-level pattern (`*/*/.git/*`) covers sub-repos cloned one directory inside the project.

```bash
zip -r -q "<project-root>/<project-folder-name>.zip" . \
  -x ".git/*" -x "*/.git/*" -x "*/*/.git/*" \
  -x ".venv/*" -x "*/.venv/*" \
  -x ".venv-win/*" -x "*/.venv-win/*" \
  -x "venv/*" -x "*/venv/*" \
  -x "node_modules/*" -x "*/node_modules/*" \
  -x "vendor/*" -x "*/vendor/*" \
  -x "dependencies/*" -x "*/dependencies/*" \
  -x "sources/*" -x "*/sources/*" \
  -x "downloaded/*" -x "*/downloaded/*" \
  -x "downloads/*" -x "*/downloads/*" \
  -x "roles/galaxy/*" -x "*/roles/galaxy/*" \
  -x "collections/ansible_collections/*" -x "*/collections/ansible_collections/*" \
  -x ".facts_cache/*" -x "*/.facts_cache/*" \
  -x ".ansible/*" -x "*/.ansible/*" \
  -x ".direnv/*" -x "*/.direnv/*"
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
