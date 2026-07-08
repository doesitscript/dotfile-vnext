# stirling_pdf

Installs the Stirling PDF desktop application on macOS using Homebrew.

## Platforms

- **macOS**: Homebrew cask via `community.general.homebrew_cask`
- **Ubuntu / Windows**: scaffolded placeholders only; no package support yet

## What it does

- Configures the `Stirling-Tools/stirling-pdf` Homebrew tap
- Installs or removes the `stirling-pdf` Homebrew cask
- Verifies that `Stirling PDF.app` exists at `/Applications/Stirling PDF.app`

## Why this role exists

Stirling PDF is available as a native macOS desktop app and can also run as a server from a JAR file.
This role focuses on the recommended Homebrew desktop install path for the macOS client.

### Desktop app benefits

- Native macOS application for Apple Silicon and Intel
- No browser required
- Local PDF processing with drag-and-drop support
- Optional self-hosted or cloud server connection modes
- Homebrew upgrade path via `brew upgrade --cask stirling-pdf`

## Installation behavior

This role uses Homebrew cask to install the native desktop app. It is compatible with the repo's existing macOS Homebrew role patterns.

If the role is later extended, the Ubuntu and Windows task files can be populated with platform-specific package management behavior.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `stirling_pdf_state` | `present` | Desired state for the Stirling PDF desktop app |
| `stirling_pdf_homebrew_tap` | `Stirling-Tools/stirling-pdf` | Tap that provides the `stirling-pdf` cask |
| `stirling_pdf_cask_name` | `stirling-pdf` | Homebrew cask name |
| `stirling_pdf_app_path` | `/Applications/Stirling PDF.app` | Expected installed app bundle path |
| `stirling_pdf_verify_install` | `true` | Verify app presence after install or removal |

## Usage

Run the role directly via the development tooling playbook:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags stirling_pdf --limit mac-dev
```

To uninstall:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags stirling_pdf --limit mac-dev \
  -e stirling_pdf_state=absent
```

## Homebrew manual reference

The equivalent Homebrew commands are:

```bash
brew tap Stirling-Tools/stirling-pdf
brew install --cask stirling-pdf
brew upgrade --cask stirling-pdf
```

## Notes

- This role is capability-named and OS-targeted internally via `tasks/main.yml`.
- It does not currently install the Stirling PDF server JAR, which is separate from the desktop client.
- If the macOS host is managed via MDM, use the repository's existing managed deployment guidance rather than this role for policy enforcement.
