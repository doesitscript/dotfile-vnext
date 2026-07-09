# homelab-dns-investigator

DNS name resolution and connection reachability investigator for the homelab from mac-dev. Produces evidence artifacts and a structured `report.md`.

## Subskills

- `subskills/published-endpoints/` — repo catalog + Kubernetes endpoint inventory

## Triggers

- DNS failures, hom.lab / .local mismatches
- guest subnet timeouts
- connectivity audit with written report

## Not for

- k9s UI → `homelab-k9s`
- kubeconfig management as primary task (see `references/connection-paths.md` for API probes only)
