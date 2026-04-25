# mas_cli

Installs the `mas` Mac App Store CLI on macOS via Homebrew.

## What this role does

1. Installs the `mas` Homebrew formula.
2. Leaves App Store sign-in and app ownership to the current Mac user.

## Why this role exists

`Speech Central` is distributed through the Mac App Store. This repo prefers a
repeatable install surface, so the App Store CLI is managed separately from the
app-install role that uses it.

## Notes

- `mas` can install only apps that the signed-in Apple account already owns.
- `mas` requires elevated privileges for install and uninstall actions.

## Variables

```yaml
mas_cli_state: present
mas_cli_formula_name: mas
```
