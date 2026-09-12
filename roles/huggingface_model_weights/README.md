# Hugging Face model weights

Owns selected Hugging Face weight trees on the Windows model share with an
Ansible `huggingface_model_weights_state: present|absent` lifecycle.

`present` uses the repo-managed `scripts/download_hf_model.py` through the
existing `roles/huggingface_hub` Python package contract. Each lane receives a
completion receipt only after `snapshot_download` returns successfully. A
missing receipt resumes an interrupted download; an existing receipt skips the
download while still verifying the receipt exists.

This role owns weights only. It does not deploy vLLM, configure LiteLLM, or
publish Continue aliases. Those promotions require separate serving and live
validation evidence.

Apply with `ansible-playbook playbooks/download_5090_models.yaml --limit
HOM-LAB-HVH-01`. Undo only with `huggingface_model_weights_state=absent` and an
explicit lane list; the role never removes the model-share root.
