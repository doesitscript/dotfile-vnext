# windows_ollama_runtime

Deploys a host-local Ollama runtime on Windows GPU hosts and keeps it suitable
for reuse behind the central LiteLLM gateway.

## Install authority

- **Windows:** `chocolatey.chocolatey.win_chocolatey` with community package
  [`ollama`](https://community.chocolatey.org/packages/ollama)
- **Model presence:** Ollama HTTP `POST /api/pull` via `ansible.windows.win_uri`
  (no shell pull loops)
- **Not used:** Galaxy role
  [`andrewrothstein.ollama`](https://galaxy.ansible.com/ui/standalone/roles/andrewrothstein/ollama/)
  — Linux-only (Alpine/Debian/EL/Ubuntu/…). It cannot manage HVH-01 Windows or
  bind the host GTX 1060 from a guest (GPU-P blocked on this host).

## Install shape note

The Chocolatey package runs official `OllamaSetup.exe` and deploys under the
WinRM user's LocalAppData
(`C:\Users\joshc\AppData\Local\Programs\Ollama` on this host). The role points
the boot scheduled task at that discovered binary. That is the community
Windows package path; it is not the same as a machine-wide Program Files zip
layout.

## What it manages

- Chocolatey-pinned Ollama package version
- machine-scoped `OLLAMA_MODELS`
- machine-scoped `OLLAMA_HOST`
- boot-triggered scheduled task for `ollama serve`
- Windows Firewall rule for the managed API port
- declared model presence through the Ollama pull API
- local runtime contract and health receipt under `C:\ProgramData\Ansible\windows_ollama_runtime`

## What it expects

- On **NVIDIA** Windows hosts: a repo-managed NVIDIA driver contract from
  `llm_compute_windows` when `windows_ollama_runtime_require_driver_contract`
  is true (default)
- On **AMD** Windows hosts (`windows_amd_gpu_hosts`): set
  `windows_ollama_runtime_require_driver_contract: false` and rely on Adrenalin
  + Ollama Vulkan (do not run `llm_compute_windows`)
- a durable model path already available on the Windows host
- Chocolatey available on the target (repo `package_manager` / existing choco)

## Primary variables

- `windows_ollama_runtime_state`
- `windows_ollama_runtime_package_version`
- `windows_ollama_runtime_bind_host`
- `windows_ollama_runtime_port`
- `windows_ollama_runtime_models_path`
- `windows_ollama_runtime_default_model`
- `windows_ollama_runtime_models_present`

## Example

```yaml
- hosts: HOM-LAB-HVH-01
  gather_facts: false
  roles:
    - role: windows_ollama_runtime
      vars:
        windows_ollama_runtime_state: present
```
