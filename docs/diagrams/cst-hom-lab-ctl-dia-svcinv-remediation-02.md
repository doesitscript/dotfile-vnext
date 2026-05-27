# Service Inventory Remediation Flow

This diagram shows the actual recovery flow used to repair the storage-lane
stack and clean up the hybrid service-inventory preview.

## Diagram

```mermaid
sequenceDiagram
    participant Mac as mac-dev
    participant Playbook as deploy_network_stacks.yaml
    participant HVH as hom-lab-ctl-hvh-01
    participant DKR as hom-lab-ctl-dkr-01
    participant Stack as stacks_fuzlang_net
    participant Preview as deploy_ipam_netbox.yaml
    participant NetBox as Live NetBox

    Mac->>Playbook: run storage-lane stack apply
    Playbook->>HVH: target Windows control host
    HVH->>DKR: delegate compose/env rendering + docker compose up
    Stack->>DKR: fix Langfuse ClickHouse env contract
    Stack->>DKR: keep MinIO on compatible image lineage
    Stack->>DKR: add S3 bucket/env wiring for Langfuse
    Stack->>DKR: add force-recreate support when config/env changes
    DKR-->>Stack: minio 200 / console 200 / langfuse 200

    Mac->>Preview: run hybrid discovery preview
    Preview->>DKR: discover Docker published ports
    Preview->>HVH: aggregate storage-lane host context
    Preview->>NetBox: compare curated model to live service objects
    Preview-->>Mac: runtime_misses=[] netbox_misses=[] runtime_unmodeled_exposures=[]
```

## Main repo changes reflected here

- `stacks_fuzlang_net` became the real recovery surface for storage-lane
  service health.
- The stack now supports forced recreation when env or compose changes matter.
- The NetBox hybrid preview now filters non-actionable loopback-only Docker
  binds and `kube-system` K3s exposures.
