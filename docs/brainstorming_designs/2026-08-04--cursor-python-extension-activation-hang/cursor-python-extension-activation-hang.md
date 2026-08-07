# Cursor Python extension activation hang — findings

**Date:** 2026-08-04  
**Host:** macOS (darwin x86_64), Cursor 3.14.7  
**Context:** multi-root workspace including `sheet_music_catalog`

## Symptoms

- Status bar: `Python extension loading…` spinner never completes
- Extensions view: **Python Debugger** (`ms-python.debugpy`) dimmed / greyed out
- Cannot select Python interpreter / use debugger

## Extensions present at failure

| Extension | Version | Notes |
|-----------|---------|-------|
| `ms-python.python` | 2025.4.0 | freshly installed (~22:54) |
| `ms-python.debugpy` | 2026.6.0-darwin-x64 | depends on Python; stays inactive if Python fails |
| `ms-python.vscode-python-envs` | 1.36.0-universal | installed earlier (Jul 8); **incompatible** |

Pylance not listed under `~/.cursor/extensions` / `cursor --list-extensions`
(marketplace claimed “already installed”).

## Log evidence

Session: `~/Library/Application Support/Cursor/logs/20260804T224951/`

### Hard activation crash (window1 `Python.log`)

```text
extension activation failed
[TypeError: Cannot read properties of undefined (reading 'onDidChangeEnvironment')]
  at createEnvExtApi (.../ms-python.python-2025.4.0/out/client/extension.js)
```

Follow-on: `No matching bindings found for serviceIdentifier: Symbol(IComponentAdapter)`.

### Python Envs (window3 `Python Environments.log`)

```text
Failed to initialize environment managers: [Error: Python extension not found]
Timed out after 30s waiting for environment manager "ms-python.python:venv"
Extension ms-python.python is installed and active but manager ... never registered
No environment managers registered
```

### Partial activate (window3 `Python.log`)

```text
Native locator: Refresh started
> pyenv which python
EnvExt: Failed to resolve environment for /usr/bin/python3
Native locator: Refresh finished in 30058 ms
Editor support is inactive since language server is set to None.
```

## Root cause

1. **Primary:** version / API mismatch between `ms-python.python` 2025.4.0 and
   `ms-python.vscode-python-envs` 1.36.0. Python activation calls EnvExt API
   (`onDidChangeEnvironment`) and crashes → spinner forever; debugpy stays grey.
2. **Contributing:** native locator (~30s) and missing/None language server
   leave editor support inactive even when partial activate succeeds.
3. **Known Cursor forum class:** native `pet` locator hangs on complex
   pyenv / legacy Framework Pythons; workaround `python.locator: "js"` +
   `python.experiments.enabled: false`.

## Applied fix (operator machine, 2026-08-04)

1. Uninstall Environments extension:
   ```bash
   cursor --uninstall-extension ms-python.vscode-python-envs
   rm -rf ~/.cursor/extensions/ms-python.vscode-python-envs-*
   ```
2. User settings (`~/Library/Application Support/Cursor/User/settings.json`):
   ```json
   "python.defaultInterpreterPath": "/usr/local/bin/python3.13",
   "python.experiments.enabled": false,
   "python.languageServer": "Pylance",
   "python.locator": "js"
   ```
3. Operator: `Developer: Reload Window`, then `Python: Select Interpreter`
   (for sheet_music: `…/sheet_music_catalog/.venv/bin/python`).

## Verify

- Status bar no longer stuck on `Python extension loading…`
- Python Debugger not greyed out
- Interpreter selectable; new logs under latest
  `…/Cursor/logs/<stamp>/…/ms-python.python/Python.log` show no
  `createEnvExtApi` / `onDidChangeEnvironment` TypeError

## Do not reinstall casually

Do **not** reinstall `ms-python.vscode-python-envs` on Cursor until
`ms-python.python` and envs versions are known-compatible (or Microsoft ships
a paired set Cursor’s marketplace actually serves). Prefer Python + debugpy
(+ Pylance when available) only.

## Related references

- Cursor forum: “Discovering Python Interpreters” spins indefinitely
- vscode-python discussion #25791 (locator / experiments)
- StackOverflow: “Reactivating terminals” / `python.locator: "js"`
