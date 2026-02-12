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
4. Exclude any file under these directories:
   - `.git`
   - `node_modules`
   - `.venv`
   - `venv`
   - `vendor`
   - `dependencies`
   - `sources`
   - `downloaded`
   - `downloads`
5. Create the zip with optimal compression.
6. Return the full archive path to the user.

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
