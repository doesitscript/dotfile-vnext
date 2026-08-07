# windows_automatic1111

Local AUTOMATIC1111 (Stable Diffusion WebUI) on Windows GPU hosts as the
Open WebUI image-generation backend. No cloud APIs. Not routed through LiteLLM.

## Lifecycle

- `windows_automatic1111_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_automatic1111.yaml` |
| **Verify** | `curl http://<host>:7860/sdapi/v1/sd-models` |
| **Undo** | `windows_automatic1111_state: absent` + re-run |
| **Change class** | Idempotent install + scheduled task; first torch/deps install is long |

## Notes

- Sized for GTX 1060 6GB (`--medvram`).
- Default checkpoint: **CyberRealistic V9 FP16** (photoreal SD1.5 for lab stills).
- ControlNet: Mikubill `sd-webui-controlnet` + OpenPose
  `control_v11p_sd15_openpose_fp16.safetensors`.
- Open WebUI Image button is fine for quick gens; use the A1111 UI for
  **denoise** and **OpenPose** when iterating poses from a reference photo.
- Denoise: ~0.35–0.45 first pass (keep identity); raise to ~0.60–0.75 when
  changing pose mid-session (and/or enable OpenPose).
- Open WebUI: `ENABLE_IMAGE_GENERATION=true`,
  `IMAGE_GENERATION_ENGINE=automatic1111`,
  `AUTOMATIC1111_BASE_URL=http://a1111-hvh01.hom.lab:7860`.
