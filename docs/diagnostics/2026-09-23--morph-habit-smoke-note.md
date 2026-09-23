# Operator note — cooling / thermal collect / k3s-02 GPU time-share (2026-09-23)

Morph habit smoke: repo pointers only (no live mutate).

## cooling_contract locations

| Surface | Path |
| --- | --- |
| Authority doc | `docs/reference/host-thermal-cooling-contracts.md` |
| Vocabulary | `policy/hardware_classes.yml` (`liquid_cooled` \| `air_cooled`) |
| HVH-02 (liquid) | `inventory/host_vars/hom-lab-hvh-02.yaml` → `cooling_contract.method: liquid`; rule `do_not_infer_idle_from_nvidia_smi_fan_speed_zero` |
| HVH-01 (air) | `inventory/host_vars/hom-lab-hvh-01.yaml` → `cooling_contract.method: air`; fan% OK with temp/power |
| Collector guidance | `roles/troubleshooting_collectors/tasks/host_thermal_cooling.yml` (`agent_guidance`) |

On liquid hosts: radiator/chassis fans are the acoustic signal; `nvidia-smi fan.speed == 0` is **not** idle proof.

## Thermal collector

- Playbook: `playbooks/troubleshoot/collect_host_thermal_cooling_artifacts.yaml`
- Role tasks: `roles/troubleshooting_collectors` → `tasks_from: host_thermal_cooling.yml`
- Tag: `collect_host_thermal`
- Artifacts: `playbooks/artifacts/troubleshooting/host_thermal_cooling/<inventory_hostname>/`

**Apply / Verify / Undo (collect only):** Apply = run the playbook above with `--limit` + `--tags collect_host_thermal` (writes local JSON under `playbooks/artifacts/…`). Verify = open the new JSON and confirm `cooling_contract` + optional `nvidia_smi_probe`. Undo = delete that host’s artifact directory (no remote state change).

## vLLM present/absent + ComfyUI mutual exclusion (k3s-02)

| Piece | Pointer |
| --- | --- |
| Flip guide | `docs/reference/k3s-02-gpu-timeshare-phase-b.md` |
| Knobs | `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` → `k3s_vllm_runtime_state` / `k3s_comfyui_runtime_state` / `k3s_ollama_runtime_state` |
| vLLM lifecycle | `roles/k3s_vllm_runtime/defaults/main.yml` defaults `k3s_vllm_runtime_state: present`; `tasks/main.yml` includes `tasks/present.yml` or `tasks/absent.yml`; entrypoint `playbooks/deploy_vllm_runtime.yaml` |
| ComfyUI role + playbook | `roles/k3s_comfyui_runtime` · `playbooks/deploy_comfyui_runtime.yaml` |

Steady-state (Phase B off): vLLM `present`, ComfyUI `absent`. Phase B on: vLLM `absent`, ComfyUI `present`. Exactly one GPU consumer; LiteLLM gateway stays up either way. Order matters — tear down the holder before bringing the other present.

## Operator don’ts

- Don’t treat `nvidia-smi fan.speed == 0` as idle on liquid-cooled HVH-02.
- Don’t diagnose fan noise without loading that host’s `cooling_contract` first.
- Don’t skip temp / power.draw / util.gpu / VRAM / vLLM logs for load answers.
- Don’t run both vLLM and ComfyUI present on k3s-02 (one `nvidia.com/gpu`).
- Don’t flip Phase B without applying **both** state knobs and the matching deploy playbooks in the documented order.
