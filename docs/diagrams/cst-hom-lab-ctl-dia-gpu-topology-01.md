# GPU Lane Topology

This diagram shows the intended post-router-fix topology for the GPU Hyper-V
lane on `HOM-LAB-HVH-02`.

## Scope

- `mac-dev`
- LAN router
- `HOM-LAB-HVH-02`
- `hom-lab-ctl-dkr-02`
- `hom-lab-ctl-k3s-02`
- direct guest-IP paths
- Windows LAN-published service paths

## Diagram

```mermaid
flowchart LR
    Mac["mac-dev\n192.168.50.33"]
    Router["LAN router\n192.168.50.1\nstatic route:\n192.168.137.0/24 via 192.168.50.158"]

    subgraph LAN["LAN 192.168.50.0/24"]
      HVH["HOM-LAB-HVH-02\nHyper-V Windows host\nLAN: 192.168.50.158\nGuest GW: 192.168.137.1"]
    end

    subgraph Guest["Hyper-V guest subnet 192.168.137.0/24"]
      DKR["hom-lab-ctl-dkr-02\nDocker VM\n192.168.137.10"]
      K3S["hom-lab-ctl-k3s-02\nK3s VM\n192.168.137.11"]
    end

    Mac --> Router --> HVH
    HVH --> DKR
    HVH --> K3S
    DKR --> HVH --> Router
    K3S --> HVH --> Router

    Direct1["Direct guest-IP path\nmac-dev -> 192.168.137.10 / .11"]
    Direct2["Whole-LAN routed reachability\nonce router route exists"]
    Publish["Windows LAN-published paths\n192.168.50.158:8000,3001,3100,30000,30400"]

    Direct1 --> DKR
    Direct1 --> K3S
    Direct2 --> Router
    Publish --> HVH

    classDef path fill:#d5f5d1,stroke:#2e7d32,color:#000;
    class Direct1,Direct2,Publish path;
```

## Key points

- `HOM-LAB-HVH-02` is the forwarding point between the LAN and the guest
  subnet.
- `hom-lab-ctl-dkr-02` and `hom-lab-ctl-k3s-02` keep their private guest IPs.
- The upstream router route is what turns this from a Mac-only direct-route
  setup into a whole-LAN routed-subnet design.
