# ollama_mac

Manage the Ollama desktop app on macOS (`mac-dev`) and ensure the `ollama` CLI
is on PATH.

## Install strategy (`ollama_mac_install_method`)

| Method | When | What |
| --- | --- | --- |
| `auto` (default) | macOS ≥ 14 → `cask`; older → `github_zip` | picks a working path |
| `cask` | Sonoma+ | Homebrew cask `ollama-app` (app + bundled CLI) |
| `github_zip` | Monterey / pre-Sonoma | pinned `Ollama-darwin.zip` (GUI min OS 11.0) |

Why two paths: current `ollama-app` cask requires **macOS 14+**. This controller
is Monterey 12.7.x, so `auto` installs pinned **0.9.6** from GitHub (verified
`LSMinimumSystemVersion` 11.0). CLI is included in the app bundle at
`Ollama.app/Contents/Resources/ollama`; the role symlinks it into Homebrew
`bin` when needed.

Upstream:

- Docs: <https://docs.ollama.com/macos>
- Cask: <https://formulae.brew.sh/cask/ollama-app>
- Releases: <https://github.com/ollama/ollama/releases>

## Lifecycle

| State | Effect |
| --- | --- |
| `present` | Install via selected method + CLI verify |
| `absent` | Remove cask/formula/app + managed CLI symlink |

## Apply / Verify / Undo / Change class

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags ollama_mac --limit mac-dev
```

- **Verify:** `test -d /Applications/Ollama.app` and `ollama --version`
- **Undo:** `-e ollama_mac_state=absent`
- **Change class:** idempotent controller-local package install
