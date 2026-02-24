# k3s Agent Role

Installs and configures k3s agent (worker node) on server-225-wsl and dev-3090-wsl.

This role:

- Installs k3s in agent mode
- Joins the cluster via API server token
- Applies node labels (gpu-compute, gpu-inference)
- Applies node taints (if configured)
- Configures systemd service

## Variables

- `k3s_version` – k3s release (default: v1.28.4)
- `k3s_api_url` – Control plane API URL (e.g., https://192.168.50.38:6443)
- `k3s_token` – Shared cluster token
- `k3s_label_node_type` – Node label for pod scheduling (e.g., gpu-compute)
- `k3s_taint_inference_only` – If true, applies inference-only taint

## Tasks

1. `main.yml` – Full setup (install, join, label, taint)
2. `firewall.yml` – WSL firewall rules (if applicable)
3. `gpu_setup.yml` – NVIDIA device plugin setup (future)

## Usage

```yaml
- include_role:
    name: k3s_agent
  vars:
    k3s_api_url: "https://192.168.50.38:6443"
    k3s_token: "{{ lookup('env', 'K3S_TOKEN') }}"
    k3s_label_node_type: "gpu-compute"
```
