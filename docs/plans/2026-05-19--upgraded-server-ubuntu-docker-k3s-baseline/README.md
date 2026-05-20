# Upgraded Server Ubuntu/Docker/K3s Baseline

## Summary

Adapt the existing Ubuntu VM, Docker VM, K3s VM, and NetBox modeling work for
the two upgraded server lanes: the storage/network server lane and the RTX 5090
GPU/inference lane.

This plan uses the active naming schema. Initial proposed resources are:

- `hom-lab-ctl-hvh-03`: storage/network Hyper-V host
- `hom-lab-ctl-hvh-04`: RTX 5090 Hyper-V host
- `hom-lab-ctl-dkr-02`: storage/network Docker/service VM
- `hom-lab-ctl-k3s-02`: storage/network K3s VM
- `hom-lab-ctl-dkr-03`: RTX 5090 Docker/service VM
- `hom-lab-ctl-k3s-03`: RTX 5090 K3s GPU VM

## Architecture/Structure Diagram

```mermaid
graph TB
    schema[docs/reference/naming-standards<br/>context hom-lab-ctl, roles hvh/dkr/k3s]
    inv[inventory/<br/>host_vars + group_vars]
    nb[roles/ipam_netbox<br/>NetBox seed/migration]
    hv[Hyper-V host baseline]
    ubu[Ubuntu VM baseline]
    dkr[Docker role/playbook lane]
    k3s[K3s role/playbook lane]

    schema --> inv
    schema --> nb
    inv --> hv
    hv --> ubu
    ubu --> dkr
    ubu --> k3s
    nb --> netbox[(NetBox<br/>Site -> Cluster -> VM -> Interface -> IP)]

    subgraph storage_network [Storage/Network Server Lane]
        hvh03[hom-lab-ctl-hvh-03]
        dkr02[hom-lab-ctl-dkr-02]
        k3s02[hom-lab-ctl-k3s-02]
    end

    subgraph gpu_lane [RTX 5090 Server Lane]
        hvh04[hom-lab-ctl-hvh-04]
        dkr03[hom-lab-ctl-dkr-03]
        k3s03[hom-lab-ctl-k3s-03]
    end

    hv --> hvh03
    hv --> hvh04
    dkr --> dkr02
    dkr --> dkr03
    k3s --> k3s02
    k3s --> k3s03
```

## Worklist

1. Reconcile inventory and NetBox seed inputs for both upgraded hosts.
2. Generalize Ubuntu baseline inputs so Docker and K3s lanes reuse the same VM
   base without crossing targets.
3. Keep Docker playbooks scoped to `dkr` VMs only.
4. Keep K3s playbooks scoped to `k3s` VMs only.
5. Add read-only target previews before any mutating run.

## Apply / Verify / Undo / Change Class

- Apply: Ansible inventory, NetBox seed/migration tasks, then existing Hyper-V
  Ubuntu/Docker/K3s playbooks by tag.
- Verify: inventory graph, NetBox object checks, SSH reachability, Docker/K3s
  exclusion checks.
- Undo: manual NetBox cleanup plus role-specific absent paths where available.
- Change class: idempotent config with bootstrap VM provisioning steps.

## Diagram Inventory

Included:

- Architecture/Structure Diagram

Other available diagram types:

- NetBox Object Hierarchy Diagram
- Host Targeting Preview Diagram
- Docker/K3s Exclusion Diagram
- Rollback Sequence Diagram
