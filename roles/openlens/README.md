# openlens

Installs the OpenLens Kubernetes IDE desktop application on macOS using the
Homebrew `openlens` cask.

Upstream sources:

- GitHub: <https://github.com/MuhammedKalkan/OpenLens>
- Homebrew cask: <https://formulae.brew.sh/cask/openlens>

## Platforms

- **macOS**: Homebrew cask via `community.general.homebrew_cask`
- **Ubuntu / Windows**: not targeted by this role

## What it does

- Installs or removes the `openlens` Homebrew cask
- Verifies that `OpenLens.app` exists at `/Applications/OpenLens.app`

## Why this role exists

OpenLens is a GUI Kubernetes IDE that fits the repo's existing `mac-dev`
tooling pattern. The upstream/Homebrew install path is straightforward, so this
role keeps the implementation small and idempotent.

## Repo integration

This role complements the repo-managed K3s client setup on `mac-dev`:

- [`k3s_mac_client`](/Users/joshc/develop/dotfile-vnext/roles/k3s_mac_client/README.md)
  manages the kubeconfig contexts and shell exports
- `openlens` manages the local desktop IDE used to browse those clusters

## Variables

| Variable | Default | Description |
|---|---|---|
| `openlens_state` | `present` | Desired state for the OpenLens desktop app |
| `openlens_cask_name` | `openlens` | Homebrew cask name |
| `openlens_app_path` | `/Applications/OpenLens.app` | Expected installed app bundle path |
| `openlens_verify_install` | `true` | Verify app presence after install or removal |

## Usage

Run the role through the development tooling playbook:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags openlens --limit mac-dev
```

To uninstall:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags openlens --limit mac-dev \
  -e openlens_state=absent
```

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags openlens --limit mac-dev`
- **Verify:** `brew list --cask openlens` and `test -d /Applications/OpenLens.app`
- **Undo:** same playbook with `-e openlens_state=absent`
- **Change class:** idempotent controller-local package install

## Homebrew manual reference

The equivalent Homebrew commands are:

```bash
brew install --cask openlens
brew upgrade --cask openlens
```
