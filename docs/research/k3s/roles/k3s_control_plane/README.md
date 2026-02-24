# k3s Control Plane Role

Installs and configures the k3s control plane (server) on network_server-wsl.

This role:

- Installs k3s in server mode with embedded etcd
- Enables cluster-init for high-availability setup
- Extracts kubeconfig for distribution to execution nodes
- Configures systemd service with proper networking
- Opens firewall ports (6443, 10250, 8472/udp, 4789/udp)

## Variables

- `k3s_version` – k3s release (default: v1.28.4)
- `k3s_api_host` – Bind IP address (default: 192.168.50.38)
- `k3s_api_port` – API server port (default: 6443)
- `k3s_token` – Shared cluster token for agent joins
- `k3s_data_dir` – Data persistence directory (default: /var/lib/rancher/k3s)

## Tasks

1. `main.yml` – Full setup (install, configure, validate)
2. `firewall.yml` – WSL firewall rules (if applicable)
3. `kubeconfig.yml` – Extract and distribute kubeconfig

## Usage

```yaml
- include_role:
    name: k3s_control_plane
  vars:
    k3s_version: v1.28.4
    k3s_token: "{{ lookup('env', 'K3S_TOKEN') }}"
```
