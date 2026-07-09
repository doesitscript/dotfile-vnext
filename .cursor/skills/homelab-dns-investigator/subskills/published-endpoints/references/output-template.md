# Published Endpoints Report

**Artifact dir:** {{artifact_dir}}
**Subskill:** homelab-published-endpoints

## Declared (repo)

| catalog_key | hostname | verify_url | source | hosts_ip | lane |
|---|---|---|---|---|---|
| {{rows from homelab_hosts_file + portproxy}} |

## Live (Kubernetes)

| cluster | namespace | kind | name | host/port | notes |
|---|---|---|---|---|---|
| {{rows from k8s-endpoints.txt}} |

Or: **blocked** — {{reason with parent connection evidence}}

## Probed (mac-dev)

| target | probe | result | notes |
|---|---|---|---|
| {{curl / nc rows}} |

Raw: `endpoint-probes.txt`

## Drift and gaps

| finding | evidence |
|---|---|
| {{repo vs k8s vs probe mismatches}} |

## Lane blockers

| lane | blocker | affected endpoints |
|---|---|---|
| {{e.g. hvh-01 down → k3s-01 catalog unreachable}} |
