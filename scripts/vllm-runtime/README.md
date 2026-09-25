# vLLM runtime workflows

These Mac-side helpers control the `vllm-primary` engine through a temporary
`kubectl port-forward`. They require
`k3s_vllm_runtime_sleep_mode_enabled: true`, which renders both
`--enable-sleep-mode` and `VLLM_SERVER_DEV_MODE=1`.

```bash
scripts/vllm-runtime/vllm-runtime-sleep.sh  # release vLLM GPU allocations
scripts/vllm-runtime/vllm-runtime-wake.sh   # reload the model into GPU memory
```

Override `VLLM_CONTEXT`, `VLLM_NAMESPACE`, `VLLM_DEPLOYMENT`, or
`VLLM_LOCAL_PORT` when targeting a different runtime.
