# k3s_vllm_runtime

Deploys an OpenAI-compatible vLLM runtime on `hom-lab-ctl-k3s-02`.

The role uses the official `vllm/vllm-openai` image pattern and fails before
mutation if the node does not expose `nvidia-smi` and Kubernetes
`nvidia.com/gpu` capacity.

## Apply

```bash
ansible-playbook playbooks/deploy_vllm_runtime.yaml -i inventory/inventory.yaml
```

## Verify

```bash
kubectl get pods -n vllm-runtime
kubectl get svc -n vllm-runtime
```

Then query the OpenAI-compatible models endpoint:

```bash
curl http://vllm-primary.vllm-runtime.svc.cluster.local:8000/v1/models
```

## References

- vLLM Docker deployment: https://docs.vllm.ai/en/latest/deployment/docker.html
- vLLM Kubernetes deployment: https://docs.vllm.ai/deployment/k8s.html
