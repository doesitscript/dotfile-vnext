# stacks_fuzlang_net

Manage the storage-lane external Langfuse data-plane services on
`hom-lab-ctl-dkr-01`:

- PostgreSQL
- Redis
- ClickHouse
- MinIO

## Lifecycle

- `stacks_fuzlang_net_state: present|absent`
- `stacks_network_purge_data_on_absent: true|false`

## Reachability contract

This role owns the guest-side containers. Cross-lane and operator consumers
should prefer the Windows-published LAN surface on `HOM-LAB-HVH-01`
(`192.168.50.234`) instead of binding themselves to the guest-direct
`192.168.138.10` address.

That publication path is declared in:

- `inventory/group_vars/all/fuzlang_external_services.yml`
- `inventory/host_vars/HOM-LAB-HVH-01.yaml`

The guest-direct VM address remains valid for SSH and maintenance, but it is
not the preferred shared service endpoint.
