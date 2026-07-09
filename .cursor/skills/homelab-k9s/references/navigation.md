# k9s navigation (homelab quick reference)

Canonical pack: `ai-resource-library/vendors/k9s/navigation-guide.md`

## Launch

```bash
kubectx hom-lab-ctl-k3s-01   # or k3s-02
k9s
```

Inside k9s: `:ctx hom-lab-ctl-k3s-02` to switch clusters.

## Essential commands

| Action | Input |
|---|---|
| Help | `?` |
| Quit | `:q` or `Ctrl-c` |
| Pods | `:pods` or `:po` |
| Services | `:svc` |
| Deployments | `:deploy` |
| Namespaces | `:ns` then pick, or `:ns litellm` |
| Contexts | `:ctx` |
| Filter list | `/pattern` |
| Describe | `d` |
| Logs | `l` |
| YAML | `y` |
| All namespaces | `Ctrl-a` (where supported) |

## Homelab namespaces

| Namespace | Cluster | Role |
|---|---|---|
| `litellm` | k3s-01 | LiteLLM gateway |
| `langfuse` | k3s-01 | Langfuse platform |
| `vllm-runtime` | k3s-02 | vLLM inference |
| `nvidia-device-plugin` | k3s-02 | GPU device plugin |
| `kube-system` | both | Core K3s / Traefik |

## Typical flows

**LiteLLM on control plane**

```text
:ctx hom-lab-ctl-k3s-01
:ns litellm
:pods
```

**vLLM on GPU node**

```text
:ctx hom-lab-ctl-k3s-02
:ns vllm-runtime
:deploy
```
