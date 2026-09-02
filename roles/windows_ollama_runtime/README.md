# windows_ollama_runtime

Deploys a host-local Ollama runtime on Windows GPU hosts and keeps it suitable
for reuse behind the central LiteLLM gateway.

## Install authority

- **Pinned `OllamaSetup.exe`:** reusable
  [`windows_artifact_download`](../windows_artifact_download/) (curl resume,
  retries, stall limits, Ansible async, checksum, atomic publish) then
  `ansible.windows.win_package` with Inno silent args.
- **Deprecated:** `chocolatey.chocolatey.win_chocolatey` for Ollama (large
  Setup.exe checksum/hang failures on interactive SSH desktops).
- **Model presence:** Ollama HTTP `POST /api/pull` via `ansible.windows.win_uri`
  (application-native; not routed through `windows_artifact_download`).
- **Large desktop model pulls:** optional background scheduled-task queue via
  `windows_ollama_runtime_model_pull_mode: background` so Ansible does not wait
  for a 30+ GB pull to finish.
- **Not used:** Galaxy role
  [`andrewrothstein.ollama`](https://galaxy.ansible.com/ui/standalone/roles/andrewrothstein/ollama/)
  — Linux-only.

## Install shape note

`OllamaSetup.exe` typically deploys under the SSH user's LocalAppData
(`C:\Users\joshc\AppData\Local\Programs\Ollama` on this host). The role points
the boot scheduled task at that discovered binary.

## What it manages

- Ollama install via `windows_artifact_download` + `win_package`
- machine-scoped `OLLAMA_MODELS` / `OLLAMA_HOST` and an optional bounded
  `OLLAMA_CONTEXT_LENGTH`
- boot-triggered scheduled task for `ollama serve` with
  `execution_time_limit: PT0S` (unlimited) so Task Scheduler does not kill the
  daemon after the Windows default of 72 hours
- Windows Firewall rule for the managed API port
- declared model presence through the Ollama pull API
- optional durable background queue for large model prefetch on desktop hosts
- local runtime contract and health receipt under `C:\ProgramData\Ansible\windows_ollama_runtime`

## What it expects

- On **NVIDIA** Windows hosts: a repo-managed NVIDIA driver contract from
  `llm_compute_windows` when `windows_ollama_runtime_require_driver_contract`
  is true (default)
- On **AMD** Windows hosts (`windows_amd_gpu_hosts`): set
  `windows_ollama_runtime_require_driver_contract: false`; rely on Adrenalin +
  Ollama Vulkan (do not run `llm_compute_windows`)
- a durable model path already available on the Windows host
- `curl.exe` available on the Windows host (system32)

## Primary variables

- `windows_ollama_runtime_state`
- `windows_ollama_runtime_package_version`
- `windows_ollama_runtime_setup_sha256`
- `windows_ollama_runtime_bind_host`
- `windows_ollama_runtime_port`
- `windows_ollama_runtime_context_length` (zero preserves Ollama's default)
- `windows_ollama_runtime_models_path`
- `windows_ollama_runtime_default_model`
- `windows_ollama_runtime_models_present`
- `windows_ollama_runtime_model_pull_mode`
- `windows_ollama_runtime_task_execution_time_limit` (default `PT0S`)
- `windows_ollama_runtime_pull_task_execution_time_limit` (default `PT0S`)

## Example

```yaml
- hosts: HOM-LAB-HVH-01
  gather_facts: false
  roles:
    - role: windows_ollama_runtime
      vars:
        windows_ollama_runtime_state: present
```
