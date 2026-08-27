# windows_iis

Ensure IIS is **not** installed on Windows Server hypervisors.

The homelab publishes HTTP via Hyper-V portproxy and K3s Traefik ingress, not IIS.
Default IIS on `:80` is accidental Windows Server residue (for example the page at
`http://ollama-hvh01.hom.lab/` when `:11434` is the real Ollama API).

## Modules (no custom removal scripts)

Uses collections already pinned in `requirements.yml`:

- `ansible.windows.win_feature_info` — detect whether `Web-Server` is installed
- `community.windows.win_iis_website` — remove default site and `:80` binding
- `ansible.windows.win_feature` — uninstall `Web-Server`

No matching Ansible Galaxy **role** exists for IIS teardown; module-based removal
is the standard pattern (same as other Windows feature roles in this repo).

## Lifecycle

- `windows_iis_state: absent` (default)

## Apply

Included in `playbooks/windows_base.yml` and full site/provision baselines.

```bash
ansible-playbook playbooks/windows_base.yml -i inventory/inventory.yaml --tags windows_iis
```

## Verify

```bash
curl -I http://ollama-hvh01.hom.lab/
# Should not return Server: Microsoft-IIS
```
