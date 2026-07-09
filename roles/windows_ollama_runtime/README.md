# windows_ollama_runtime

Deploys a host-local Ollama runtime on Windows GPU hosts and keeps it suitable
for reuse behind the central LiteLLM gateway.

## What it manages

- official standalone Ollama Windows runtime archive
- machine-scoped `OLLAMA_MODELS`
- machine-scoped `OLLAMA_HOST`
- boot-triggered scheduled task for `ollama serve`
- Windows Firewall rule for the managed API port
- declared model presence through `ollama pull`
- local runtime contract and health receipt under `C:\ProgramData\Ansible\windows_ollama_runtime`

## What it expects

- a repo-managed NVIDIA driver contract from `llm_compute_windows`
- a durable model path already available on the Windows host

## Primary variables

- `windows_ollama_runtime_state`
- `windows_ollama_runtime_bind_host`
- `windows_ollama_runtime_port`
- `windows_ollama_runtime_models_path`
- `windows_ollama_runtime_default_model`
- `windows_ollama_runtime_models_present`

## Example

```yaml
- hosts: hom-lab-hvh-01
  gather_facts: false
  roles:
    - role: windows_ollama_runtime
      vars:
        windows_ollama_runtime_state: present
```
