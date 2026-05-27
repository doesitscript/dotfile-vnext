# GPU Lane Control Paths

This diagram shows how the main operator and automation paths relate to the GPU
Hyper-V lane resources.

## Diagram

```mermaid
flowchart LR
    Mac["mac-dev\ncontroller / operator node"]
    HVH["hom-lab-ctl-hvh-02\nHyper-V Windows host"]
    DKR["hom-lab-ctl-dkr-02\nDocker VM"]
    K3S["hom-lab-ctl-k3s-02\nK3s VM"]
    NetBox["NetBox service\non hom-lab-ctl-dkr-02"]
    Docker["Docker Engine\non hom-lab-ctl-dkr-02"]
    K3SRuntime["K3s runtime\non hom-lab-ctl-k3s-02"]
    Published["LAN-published service endpoints\nvia 192.168.50.158"]

    Mac -->|"SSH / Ansible to Windows host"| HVH
    Mac -->|"ProxyJump SSH / Ansible"| DKR
    Mac -->|"ProxyJump SSH / Ansible"| K3S
    Mac -->|"direct routed HTTP"| NetBox
    Mac -->|"Docker client over SSH"| Docker

    HVH -->|"Hyper-V guest hosting"| DKR
    HVH -->|"Hyper-V guest hosting"| K3S
    HVH -->|"Windows portproxy"| Published

    DKR --> NetBox
    DKR --> Docker
    K3S --> K3SRuntime

    Published -->|"8000"| NetBox
    Published -->|"30000 / 30400"| K3SRuntime

    classDef ctl fill:#dbeafe,stroke:#1d4ed8,color:#000;
    classDef guest fill:#d5f5d1,stroke:#2e7d32,color:#000;
    class Mac,HVH,Published ctl;
    class DKR,K3S,NetBox,Docker,K3SRuntime guest;
```

## What this clarifies

- `mac-dev` is the controller and operator node.
- `hom-lab-ctl-hvh-02` is the Windows host and port publication surface.
- `hom-lab-ctl-dkr-02` is both the Docker engine endpoint and the NetBox host.
- `hom-lab-ctl-k3s-02` is the K3s service lane.
- Direct routed guest-IP access and LAN-published Windows access are parallel
  access patterns, not the same thing.
