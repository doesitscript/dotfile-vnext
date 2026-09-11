# Decisions and Apply authority

Campaign: `hrl-storage-implementation-beta-01`.

Launching the supplied Implementer prompt authorizes repository implementation
and relevant read-only discovery. Authoring this packet is not evidence that a
live Apply has already occurred.

## Authority profile and adopted Expert defaults

This campaign uses `lab_recreatable_autonomy` from
`multi-agent-design/decision-authority-profiles.md`: it is a non-production,
recreatable homelab with no availability commitment. Evidence-backed Expert
defaults are therefore adopted as campaign technical decisions within the
declared scope. Exact target identity, preview/fail-closed checks, receipts,
and independent Evaluator review remain mandatory.

The adopted recommendation is
`eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md`.
An unknown guest by-id path or changed Hyper-V attachment slot requires the
narrow read-only probe needed to bind that identity; it does not reopen a human
decision wait. A future product selects `product_governed` instead.

| Slice | Verified target and evidence | Decision / selected values | User authority reference and allowed action | Preview / baseline / backup / Undo | State |
| --- | --- | --- | --- | --- | --- |
| S1 | Guest `hom-lab-ctl-k3s-02` and parent `HOM-LAB-HVH-02`; `receipts/2026-09-11T065746Z-s1-storage-discovery.md` | Read-only inventory/owner discovery | Supplied Implementer launch prompt | Exact inventory limits; no mutation | Evidence captured |
| S2 | Exact guest above; K3s 1.31.12 embeds containerd 2.0.5, generates the only observed `config.toml`, and exposes kubelet image-GC thresholds 85/80; about 368 KiB of exited/sandbox layers and zero eligible image bytes | **Source-backed no-change recommendation:** keep kubelet as normal GC owner; do not add a custom containerd template, external prune timer, deletion or restart for this incident. Solve backing capacity in S3/S4. | No mutation authority requested because no S2 mutation is justified | Preserve current generated config, NVIDIA runtime and CNI state; no S2 undo is needed unless future evidence selects a change | No Apply recommended; Evaluator review requested |
| S3 | Bound local-path vLLM PVC on guest root; actual cache 22 GiB; present-state role now fails closed on unverified backing | **Adopted Best recommendation:** move the vLLM HuggingFace cache to the S4 mount, keep the original cache until pod health/DiskPressure/root-use success criteria pass, then delete it; do not use PVC deletion as relocation. | Lab profile adopts the bounded cutover after S4 target/mount verification. Cache is retained as the cutover rollback source until success evidence exists. | `k3s_vllm_runtime_hf_cache_backing_capacity_verified` remains false until actual capacity evidence is recorded; rollback restores `HF_HOME`/PVC path before original-cache deletion. | Awaiting S4 and verification |
| S4 | Running K3s VM has one fixed 80 GiB VHDX on host D:; D: has 373.6 GiB free; state-aware lifecycle and safety-verification playbooks now exist | **Adopted Preference:** second fixed 200 GiB VHDX at `D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-k3s-02\hom-lab-ctl-k3s-02-data.vhdx`, 50 GiB host reserve, SCSI `0:1`, guest mount `/mnt/k3s-cache`; derive partition 1 and discover guest by-id/serial after attach. | Lab profile adopts the values after read-only confirmation that slot `0:1` remains free. The three final Evaluator S4 source corrections and their tests remain required before Apply. | Preview and apply recheck reserve; exact host path/slot and post-attach by-id/serial are fail-closed identity gates. Absent removes persistent intent before exact detach; VHDX/filesystem data remain preserved. | Corrections pending; then scoped lab Apply eligible |
| S5 | No Prometheus-family API resources or storage-retention timer; existing path is journald → Alloy → Loki/Grafana | **Adopted Preference:** current-stack-first host-native systemd timer; hourly checks for `/` and `/mnt/k3s-cache`; journald → Alloy → Loki/Grafana; warning 75%, critical 90%; use existing Loki retention. | Lab profile adopts this no-new-service approach. Escalate to Prometheus/Alertmanager only if a future paging/on-call requirement is recorded. | Disable/remove timer/rules to reverse; preserve logs under existing Loki retention. | Ready for bounded implementation after S4 mount exists |

For an unresolved choice, record the smallest concrete question, recommendation,
evidence, risk and affected slice. Continue independent authorized work.
Do not store credentials, vault contents, tokens or unredacted secret diffs here.
