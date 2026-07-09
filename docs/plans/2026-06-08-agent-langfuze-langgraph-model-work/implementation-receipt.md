# Langfuse Agent Stack Alignment Receipt

## Date

- 2026-07-08

## Applied repo changes

- Promoted the LiteLLM gateway contract so `code-deep` is a real local lane and
  `experiment` remains a temporary smoke alias on the same `vllm-primary`
  backend.
- Preserved migration rows `gpt-4o-mini` and `default` in the main LiteLLM
  route list.
- Added an explicit LiteLLM lane contract surface so blocked lanes stay visible
  in config and validation instead of disappearing from the repo contract.
- Promoted the vLLM runtime default model to
  `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ`.
- Added `playbooks/validate_ai_inference_stack_contracts.yaml` and wired it into
  `playbooks/deploy_ai_inference_stack.yaml`.
- Updated endpoint verification to probe the live Langfuse/LiteLLM operator
  surfaces that currently respond on the GPU lane.
- Tightened Cursor client guidance so local-model setup stays on the LiteLLM
  gateway with lane aliases rather than raw runtime URLs or raw upstream model
  names.

## Validation completed

- `ansible-playbook playbooks/validate_ai_agent_client_profiles.yaml`
- `ansible-playbook playbooks/validate_ai_inference_stack_contracts.yaml`
- `ansible-playbook playbooks/validate_ai_inference_stack_contracts.yaml --syntax-check`
- `ansible-playbook playbooks/deploy_ai_inference_stack.yaml --syntax-check`

All four passed. The NetBox inventory plugin emitted existing API permission
warnings during local playbook startup, but those warnings did not fail the
validation runs.

## Live runtime probes captured during implementation

- `http://192.168.50.158:30000/api/public/health` returned `200`
- `http://192.168.50.158:30400/health` returned `401`
- `http://192.168.50.234:9000/minio/health/live` returned `200`
- External data-plane port checks from the controller showed
  `192.168.50.234:{5432,6379,8123,9000}` open

## Convergence result

`ansible-playbook playbooks/deploy_ai_inference_stack.yaml -i inventory/inventory.yaml`
did **not** finish. It stopped at the existing GPU prerequisite gate on
`hom-lab-ctl-k3s-02` before vLLM mutation:

- `nvidia-smi` not found on `hom-lab-ctl-k3s-02`
- Kubernetes node capacity does not currently advertise `nvidia.com/gpu`

That means the repo/runtime contract work in this slice is applied, but the
first real local vLLM lane cannot converge until the K3s GPU substrate is
commissioned on `hom-lab-ctl-k3s-02`.

## Follow-up blocker to resolve

- The immediate missing prerequisite is on the Hyper-V host, not inside the
  Ubuntu guest. `Get-VMHost` on `HOM-LAB-HVH-02` currently reports
  `IovSupport=False` with BIOS/PCIe ACS reasons, so GPU partition startup fails
  before guest-side NVIDIA packages can matter.
- Repo work completed in this slice:
  - added `hyperv_gpu_partition_adapter` with SR-IOV preflight so future runs
    fail early instead of re-attaching GPU-P and leaving the VM offline
  - added `k3s_nvidia_runtime` for pinned guest driver/toolkit installation
  - added `k3s_nvidia_device_plugin` plus GPU node-label surfaces and vLLM
    `runtimeClassName: nvidia`
- Remaining external prerequisite:
  - enable the required BIOS/PCIe SR-IOV/ACS support on the physical Hyper-V
    platform backing `HOM-LAB-HVH-02`, or move the GPU lane to hardware
    that exposes supported GPU partition prerequisites
- Once that host prerequisite is satisfied:
  - re-run `playbooks/deploy_gpu_infrastructure.yaml`
  - re-run `playbooks/deploy_ai_inference_stack.yaml`
  - verify the `code-deep` and `experiment` LiteLLM routes against the live
    `vllm-primary` backend once the node advertises GPU capacity
