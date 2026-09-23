# Diagnostic — HVH-02 fan acoustics vs liquid cooling (2026-09-22)

## Symptom

Operator heard higher fan activity on `HOM-LAB-HVH-02` after AI model-lane
pytest against LiteLLM / `qwen3-coder-30b-a3b`, with no concurrent human work.

## Initial agent evaluation (incomplete)

Probes showed:

- CPU load ~1%
- RTX 5090: temp 30°C, **fan.speed 0%**, util 0%, power ~4.5 W
- VRAM ~29 GB resident (`vllm-primary` weights)
- vLLM logs: brief throughput spike then idle

The agent concluded “GPU not under load; maybe Corsair chassis fans or residual
sound.” That was directionally OK on **compute idle**, but **missed** the
facility cooling model: HVH-02 is **fully water-cooled**. Corsair fans sit on
**radiators** and follow a **curve**, so audible ramp is expected after GPU
work even when onboard GPU fan % stays 0.

## Correction encoded in repo

- `cooling_contract` on HVH-01 (`air`) and HVH-02 (`liquid`)
- `hardware_classes`: `air_cooled` / `liquid_cooled`
- `docs/reference/host-thermal-cooling-contracts.md`
- Troubleshooting rule + `collect_host_thermal` collector

## Better evaluation rule (for future agents)

On liquid-cooled HVH-02, do **not** treat `nvidia-smi fan.speed == 0` as proof
of thermal idle. Use temp/power/util + radiator/chassis fan behavior +
`cooling_contract.agent_rules`.
