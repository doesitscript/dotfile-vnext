# k3s_vllm_runtime

Deploys an OpenAI-compatible vLLM runtime on `hom-lab-ctl-k3s-02`.

The role uses the official `vllm/vllm-openai` image pattern and fails before
mutation if the node does not expose `nvidia-smi` and Kubernetes
`nvidia.com/gpu` capacity.

## Vault

| Vault file | Variable |
| --- | --- |
| `vault/shared.vault.yml` | `vault_hf_token` — written into the vLLM env Secret as `HF_TOKEN` when set |

```bash
bin/codex-env ansible-vault edit vault/shared.vault.yml
# vault_hf_token: "hf_..."
```

## Apply

```bash
ansible-playbook playbooks/deploy_vllm_runtime.yaml -i inventory/inventory.yaml
```

## Verify

```bash
kubectl get pods -n vllm-runtime
kubectl get svc -n vllm-runtime
kubectl get secret -n vllm-runtime vllm-primary-env
```

Then query the OpenAI-compatible models endpoint:

```bash
curl http://vllm-primary.vllm-runtime.svc.cluster.local:8000/v1/models
```

## References

- vLLM Docker deployment: https://docs.vllm.ai/en/latest/deployment/docker.html
- vLLM Kubernetes deployment: https://docs.vllm.ai/deployment/k8s.html
