# Typical flows — homelab-k9s

k9s is only useful after `homelab-dns-investigator` confirms the kubectl API path is up. These flows assume a working context.

## Prerequisite check

```bash
kubectl config current-context
kubectl --request-timeout=10s get nodes
```

| context | when usable | blocked example |
|---|---|---|
| `hom-lab-ctl-k3s-01` | hvh-01 (`50.234`) up, `138.11:6443` open | hvh-01 down — do not debug k9s; fix gateway first |
| `hom-lab-ctl-k3s-02` | hvh-02 lane up, `137.11:6443` open | use after DNS report shows k3s-02 reachable |

## LiteLLM / Langfuse (control plane services)

Declared on k3s-01 in inventory; **in practice** NodePorts may be published via hvh-02 portproxy to k3s-02 (`50.158:30000` / `:30400`). Confirm which cluster actually serves traffic before picking `:ctx`.

When k3s-01 API is up:

```text
:ctx hom-lab-ctl-k3s-01
:ns litellm
:pods
```

```text
:ctx hom-lab-ctl-k3s-01
:ns langfuse
:deploy
```

When only k3s-02 is reachable (common when hvh-01 is down):

```text
:ctx hom-lab-ctl-k3s-02
:ns litellm
:pods
```

## vLLM / GPU runtime

```text
:ctx hom-lab-ctl-k3s-02
:ns vllm-runtime
:deploy
```

```text
:ctx hom-lab-ctl-k3s-02
:ns nvidia-device-plugin
:pods
```

## Namespace map (homelab)

| Namespace | Cluster | Role |
|---|---|---|
| `litellm` | k3s-01 (declared) / often k3s-02 (live) | LiteLLM gateway |
| `langfuse` | k3s-01 (declared) / often k3s-02 (live) | Langfuse platform |
| `vllm-runtime` | k3s-02 | vLLM inference |
| `nvidia-device-plugin` | k3s-02 | GPU device plugin |
| `kube-system` | both | Core K3s / Traefik |

## Launch sequence

```bash
kubectx hom-lab-ctl-k3s-02
k9s
```

Inside k9s: `?` help, `:q` quit, `/pattern` filter, `l` logs, `d` describe, `y` yaml.

## When k9s shows empty or errors

Do not tune k9s — return to `homelab-dns-investigator`:

- API timeout → connection-probes for guest IP and hypervisor gateway
- Wrong cluster → `:ctx` or `kubectx` per DNS report working paths
- Service URL works in browser but pods missing → `homelab-published-endpoints` subskill for declared vs live drift
