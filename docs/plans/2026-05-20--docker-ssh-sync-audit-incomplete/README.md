---
name: Docker SSH sync audit
overview: Audit whether the Docker client/server setup is in sync with the SSH config setup, and identify why `docker run` is currently failing with connection refused.
todos: []
isProject: false
---

# Docker Client / SSH Setup — Sync Audit

## Answer: The systems are in sync by design

The Docker client and SSH config are **coupled through a deliberate Ansible pipeline**. Here is the full dependency chain:

```mermaid
flowchart TD
    A["access.yaml runs"] --> B["access_identity_windows on hom-lab-ctl-hvh-02\n(ubuntu.yml)"]
    B --> C["Sets ssh_configured=true as cacheable\ndelegatefact on server-225-wsl"]
    C --> D["access_identity_controller ssh_config.yml\ntemplates ~/.ssh/config"]
    D --> E["Host server-225-wsl\nHostName 192.168.50.222\nPort 22\nIdentityFile ~/.ssh/id_ed25519_ansible"]
    E --> F["docker_client role on mac-dev\ncreates Docker context\nssh://joshc@server-225-wsl:22"]
    F --> G["docker run uses SSH tunnel\nthrough ~/.ssh/config alias"]
```



### How the SSH alias gets into `~/.ssh/config`

- `[roles/access_identity_windows/tasks/ubuntu.yml](roles/access_identity_windows/tasks/ubuntu.yml)` line 777: at the end of Windows SSH setup, it runs `delegate_to: server-225-wsl` and sets `ssh_configured: true` as a **cacheable fact** on the WSL companion host, along with `ssh_host`, `ssh_port`, `ssh_user`
- `[roles/access_identity_controller/tasks/ssh_config.yml](roles/access_identity_controller/tasks/ssh_config.yml)`: the template loops `groups['ssh_targets']` and only emits entries for hosts where `ssh_configured=true` — this produces the `Host server-225-wsl` block
- `ssh_configured: true` is now also declared in `[inventory/host_vars/server-225-wsl.yaml](inventory/host_vars/server-225-wsl.yaml)` as the inventory SSOT for desired state. Variable precedence means the cached fact still wins at runtime (precedence 18 vs 8); the inventory value is the fallback when the cache is cold.

### How the Docker context depends on the SSH alias

- `[inventory/host_vars/mac-dev.yaml](inventory/host_vars/mac-dev.yaml)`: `docker_engine_ssh_host: "server-225-wsl"` — a symbolic reference to the SSH alias, not an IP
- `[roles/docker_client/tasks/main.yml](roles/docker_client/tasks/main.yml)`: inspects the existing context, compares the current endpoint against the expected value, and removes/recreates if they differ — **self-healing on every run**
- The Docker context therefore requires the SSH config alias to exist and to be valid before any `docker` command can succeed

### IP address / endpoint drift

`ansible_host` in `[inventory/host_vars/server-225-wsl.yaml](inventory/host_vars/server-225-wsl.yaml)` is router-managed and has not been observed to change. If it ever does: update `ansible_host` and re-run `access.yaml` + `docker_client.yaml`. The docker_client role detects the endpoint change and self-corrects the context — no further intervention needed.

### WSL idle-shutdown / sshd not running

**Addressed.** The WSL keepalive scheduled task in `[roles/access_identity_windows/tasks/ubuntu.yml](roles/access_identity_windows/tasks/ubuntu.yml)` (line 813) runs `wsl.exe -d Ubuntu-24.04 -u root -- sleep infinity` at both boot and logon via `community.windows.win_scheduled_task`. This holds a permanent wsl.exe session open — WSL's idle timer never fires. The pre-task in `docker.yaml` is retained as a belt-and-suspenders safety net.

## Resolved items


| Item                                   | Resolution                                                                                                                                                                 |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ssh_configured` fact-cache dependency | `ssh_configured: true` added to `host_vars/server-225-wsl.yaml` and `host_vars/network-server-wsl.yaml` as inventory SSOT. Cache is no longer the single point of failure. |
| Bridged IP change concern              | Router-managed comment added to all wsl host_vars files. Docker context self-heals. No operational steps warranted.                                                        |
| WSL idle-shutdown / sshd not running   | WSL keepalive scheduled task eliminates the root cause.                                                                                                                    |
| Docker context endpoint drift          | docker_client role already self-heals (inspect → compare → remove → recreate).                                                                                             |
| `dev-3090-wsl`                         | Not yet deployed. `ssh_configured: true` must be added to its host_vars after `access.yaml` runs against `dev-3090-win` and SSH is confirmed working.                      |
