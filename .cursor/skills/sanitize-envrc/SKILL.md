---
name: sanitize-envrc
description: >-
  Reads .envrc, creates or updates .envrc.sample with sanitized placeholder
  values safe for committing, and ensures .envrc is in .gitignore. Use when
  adding secrets to .envrc, setting up a new project environment, creating a
  sample env file, protecting secrets from git, or when asked to sanitize,
  clean, or document environment variables.
---
# Sanitize envrc

## Steps

1. Read `.envrc` from project root
2. Produce `.envrc.sample` with secret values replaced by obvious fake values
3. Confirm `.envrc` is in `.gitignore` — add it if missing

## Secret detection

A variable is a secret when its name contains (case-insensitive):
`KEY`, `SECRET`, `TOKEN`, `PASSWORD`, `PASS`, `CREDENTIAL`, `AUTH`, `APIKEY`, `API_KEY`

## Value rules

| Variable type | Output in sample |
|---|---|
| Secret variable | `"your_VARNAME_here"` |
| Boolean-like value (`yes`, `no`, `true`, `false`, `*`) | Keep as-is |
| Simple flag variable (non-secret name) | Keep as-is |
| Comment lines | Keep as-is |
| Blank lines | Keep as-is |

## .envrc.sample header

Always write this as the first non-blank line:

```bash
# Copy this file to .envrc and fill in secret values. Do NOT commit .envrc.
```

## Example

Input `.envrc`:
```bash
# Required for WinRM / Ansible on macOS
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes
export no_proxy=*
export APIKEY="sk-proj-abc123..."
export GITHUB_TOKEN="ghp_realtoken"
```

Output `.envrc.sample`:
```bash
# Copy this file to .envrc and fill in secret values. Do NOT commit .envrc.
# Required for WinRM / Ansible on macOS
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes
export no_proxy=*
export APIKEY="your_APIKEY_here"
export GITHUB_TOKEN="your_GITHUB_TOKEN_here"
```

## .gitignore check

Search `.gitignore` for `.envrc`. If not present, append:

```
# secrets — do not commit
.envrc
```

Use `Grep` to check before appending — never duplicate the entry.

## After writing

Run `git status` to confirm `.envrc.sample` shows as a new/modified file and `.envrc` does not appear as tracked.
