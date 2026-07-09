---
name: homelab-k9s
description: Navigate homelab K3s clusters with k9s — colon commands, context and namespace switching, resource views, and homelab namespace map. Use when the user asks about k9s, terminal Kubernetes UI, or browsing pods/services/deployments on hom-lab-ctl-k3s-01/02.
---

# Homelab k9s

k9s TUI workflow for this repo's two K3s contexts from `mac-dev`.

## Prerequisites

Correct kubectl context must be reachable before k9s is useful. If API calls fail, use `homelab-dns-investigator` for DNS and connection evidence — do not debug k9s UI when the cluster path is down.

## Context map

| k9s `:ctx` | Lane | Common namespaces |
|---|---|---|
| `hom-lab-ctl-k3s-01` | Control plane | `litellm`, `langfuse`, `kube-system` |
| `hom-lab-ctl-k3s-02` | GPU runtime | `vllm-runtime`, `nvidia-device-plugin`, `kube-system` |

## Workflow

1. **Confirm context** — outside k9s: `kubectl config current-context`; inside: `:ctx`
2. **Switch cluster** — `:ctx hom-lab-ctl-k3s-01` or `:ctx hom-lab-ctl-k3s-02`
3. **Switch namespace** — `:ns <name>` or `:ns` to pick from list
4. **View resources** — `:pods`, `:svc`, `:deploy`
5. **Inspect** — `d` describe, `l` logs, `y` YAML, `/pattern` filter

## Typical flows

**LiteLLM (control plane)**

```text
:ctx hom-lab-ctl-k3s-01
:ns litellm
:pods
```

**vLLM (GPU node)**

```text
:ctx hom-lab-ctl-k3s-02
:ns vllm-runtime
:deploy
```

## Authority

| Topic | SSOT |
|---|---|
| Full navigation reference | `ai-resource-library/vendors/k9s/navigation-guide.md` |
| Commands reference | `ai-resource-library/vendors/k9s/commands-reference.md` |
| kubectl contexts / reachability | `homelab-dns-investigator` skill |

## References

- [references/navigation.md](references/navigation.md)

## Examples

- [examples/typical-flows.md](examples/typical-flows.md) — context prerequisites, litellm/langfuse/vllm flows, when to defer to dns-investigator
