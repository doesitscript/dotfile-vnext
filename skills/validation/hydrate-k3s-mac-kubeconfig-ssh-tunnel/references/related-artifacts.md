# Related Artifacts

## Apply

```bash
bin/codex-env ansible-playbook playbooks/k3s_mac_client.yaml \
  -i inventory/inventory.yaml --tags k3s_mac_client --limit mac-dev
```

## Typical tunnel ports (`mac-dev` when on ssh_tunnel)

| Context | Local port |
| --- | --- |
| `hom-lab-ctl-k3s-01` | 16443 |
| `hom-lab-ctl-k3s-02` | 26443 |

## Separate configs

Prefer:

```yaml
k3s_mac_client_manage_default_kubeconfig: false
k3s_mac_client_shell_kubeconfig_export: true
```

Legacy discoverability name: `.cursor/skills/kubeconfig-context-hydrator` bridges to this skill.
