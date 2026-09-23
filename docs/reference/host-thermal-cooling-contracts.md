# Host thermal / cooling contracts

Authority for chassis cooling facts used by Ansible inventory and AI
troubleshooting. Host-specific values live on `cooling_contract` in
`inventory/host_vars/<host>.yaml`. Vocabulary: `policy/hardware_classes.yml`
(`liquid_cooled` | `air_cooled`).

## Why this exists

Datacenter-style ops separate **compute load telemetry** from **facility
cooling acoustics**. On liquid-cooled hosts, radiator / chassis fans often
ramp on a curve after CPU/GPU work while the GPU’s own fan reports **0%**
(pump + radiators carry heat). Agents that treat `nvidia-smi fan.speed == 0`
as “idle / no workload” will mis-diagnose those hosts.

## Inventory fields (`cooling_contract`)

| Field | Meaning |
| --- | --- |
| `method` | `liquid` or `air` |
| `loop_class` | e.g. `closed_loop_radiator` or `none` |
| `fan_controller` | e.g. `corsair_icue`, `motherboard_and_gpu` |
| `radiator_fans` | `curve_controlled` or `none` |
| `primary_acoustic_signal` | What humans hear when “fans spin up” |
| `gpu_onboard_fan_telemetry` | `often_zero_or_not_load_proxy` vs `meaningful_for_load` |
| `agent_rules` | Explicit do/don’t list for probes |

## Homelab map (2026-09-22)

| Host | Cooling | Acoustic proxy | Do not use alone |
| --- | --- | --- | --- |
| `HOM-LAB-HVH-02` | **Liquid** (Corsair curve → radiators) | Radiator / chassis fans | `nvidia-smi fan.speed` |
| `HOM-LAB-HVH-01` | **Air** | GPU + case fans | — (fan% is OK with temp/power) |

HVH-02 also hosts the RTX 5090 lane (`hom-lab-ctl-k3s-02` / `vllm-primary`).
Inference traffic can raise coolant load and radiator fan RPM **after** the
request finishes; that cooldown is expected.

## Agent evaluation checklist

1. Load `cooling_contract` for the physical host (or Hyper-V parent) **before**
   interpreting fan noise.
2. Prefer: GPU **temp**, **power.draw**, **utilization.gpu**, VRAM residency,
   Hyper-V VM CPU, and service logs (e.g. vLLM throughput) over GPU fan %.
3. On `method: liquid`, treat post-workload radiator ramp as cooldown unless
   util/power/temp stay elevated.
4. Collect with tag `collect_host_thermal` when thermal acoustics are in scope.

## Collector

```bash
ansible-playbook playbooks/troubleshoot/collect_host_thermal_cooling_artifacts.yaml \
  -i inventory/inventory.yaml --limit HOM-LAB-HVH-02 --tags collect_host_thermal
```
