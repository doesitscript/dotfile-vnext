# huggingface_hub

Manages the Hugging Face Hub Python package (`huggingface_hub`) and `hf` CLI
on Windows GPU/storage hosts via `py -m pip`.

## Lifecycle

- `huggingface_hub_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_huggingface_hub.yaml --limit HOM-LAB-HVH-01` |
| **Verify** | `py -c "import huggingface_hub; print(huggingface_hub.__version__)"` on the host |
| **Undo** | `-e huggingface_hub_state=absent` on the same playbook |
| **Change class** | Idempotent package install |

## Notes

- Requires Windows OpenSSH/PowerShell inventory surface and a working `py` launcher
  (see `roles/python` Chocolatey Python install).
- Pin with `huggingface_hub_package_version` when a version contract is set.
- Model weight downloads are a **separate** capability (must own `present|absent`
  for share trees). This role only owns the Hub client package.
