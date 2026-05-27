# network_server (deprecated umbrella)

Sub-roles formerly nested under `roles/network_server/` were promoted to
top-level capability roles:

- `roles/stacks_fuzlang_net/` — fuzlang network Docker Compose stack
- `roles/hyperv_docker_runtime/` — Hyper-V Ubuntu Docker engine runtime prep
- `roles/hyperv_storage_layout/` — Hyper-V host storage layout

Do not add new sub-roles here. Extend the promoted roles or compose them from
playbooks instead.
