# windows_lab_studio

Deploys lab studio seed assets (prompts, coaching, examples,
directory layout) onto the Windows public share for documented A1111 and
ComfyUI end-to-end still solutions.

Assets match the documented Automatic1111 and ComfyUI plan packets.

Does **not** install A1111, ComfyUI, or model weights. Phase A pixels remain
`windows_automatic1111`; Phase B pixels remain `k3s_comfyui_runtime`.

## Lifecycle

- `windows_lab_studio_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_lab_studio.yaml` |
| **Verify** | Share tree under `F:\shares\public\studio` contains lab_doc / mock prompts |
| **Undo** | `windows_lab_studio_state: absent` + re-run |
| **Change class** | Idempotent share seed |
