# k3s_coredns_homelab_hosts

Publish interim `*.hom.lab` names from `homelab_hosts_file_web_catalog` into
K3s CoreDNS so **pods** resolve the same hostnames as mac/Linux/Windows hosts
files.

## Why

OS hosts-file playbooks only update `/etc/hosts` on nodes. Pods use CoreDNS,
which does not read node hosts files. Without this role, LiteLLM (and other
pods) fail DNS for `ollama-desktop.hom.lab` / `ollama-hvh01.hom.lab`.

K3s already imports optional custom config:

```text
import /etc/coredns/custom/*.server
```

mounted from ConfigMap `coredns-custom` (optional).

## Lifecycle

- `k3s_coredns_homelab_hosts_state: present|absent`
- Present: merge key `hom.lab.server` into `coredns-custom`, restart CoreDNS,
  nslookup probe for `ollama-desktop.hom.lab`
- Absent: remove only this role's key; delete ConfigMap if empty

## Catalog filter

Includes catalog rows where:

- `hostname` ends with `.hom.lab`
- `hosts_ip` is set
- `coredns_hosts_enabled` is not `false` (optional opt-out)

## Apply

```bash
ansible-playbook playbooks/deploy_k3s_coredns_homelab_hosts.yaml
```

Also imported from `playbooks/homelab_hosts_file.yaml`.

## Verify

```bash
kubectl -n litellm exec deploy/litellm -- \
  python -c 'import socket; print(socket.getaddrinfo("ollama-desktop.hom.lab",11434)[0][4][0])'
```

## Undo

```bash
ansible-playbook playbooks/deploy_k3s_coredns_homelab_hosts.yaml \
  -e k3s_coredns_homelab_hosts_state=absent
```
