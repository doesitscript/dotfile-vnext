# OpenSSH Server Diagnostic Sources

Platform: Ubuntu 24.04 on WSL2 (systemd enabled)

## Current State (observed 2026-03-10)

`openssh-server` is **not installed** in the Ubuntu-24.04 WSL distro.

```
un  openssh-server <none>  <none>  (no description available)
```

`un` = dpkg status unknown/not-installed. No `ssh.service`, no `ssh.socket`, no
`/etc/ssh/sshd_config.d/` drop-ins exist.

---

## Logging Locations

| Source | Path / Command | Notes |
|--------|---------------|-------|
| systemd journal | `journalctl -u ssh` | Primary on Ubuntu 24.04 with systemd |
| auth.log | `/var/log/auth.log` | Syslog fallback; sshd writes `authpriv` facility |
| Real-time follow | `journalctl -fu ssh` | Streams new entries as they arrive |
| Verbose debug | `journalctl -u ssh --since -10m` | Narrow to recent window |

## Diagnostic Commands

```bash
# Installation state
dpkg -l openssh-server

# Service / socket state (Ubuntu 24.04 uses socket activation)
systemctl status ssh.service --no-pager
systemctl status ssh.socket --no-pager
systemctl is-enabled ssh.socket

# Live log (journal)
journalctl -u ssh --no-pager -n 50

# Live log (auth.log fallback)
grep sshd /var/log/auth.log | tail -30

# Port listening check
ss -tlnp | grep ':22'

# Config validation
sshd -t              # test config, exits 0 if valid
sshd -T              # dump effective config

# Debug mode — run a second sshd on a spare port, watch output in terminal
sshd -d -p 2244      # single-connection debug (dies after one connection)
sshd -ddd -p 2244    # maximum verbosity

# Host key fingerprints
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
```

## Event / Channel Sources

- systemd unit: `ssh.service` and `ssh.socket` (Ubuntu 24.04 uses socket activation)
- journald identifier: `sshd`
- syslog facility: `authpriv` → `/var/log/auth.log`

## Vendor / Tooling Diagnostics

- `sshd -t` — config syntax check, mandatory before restarting after edits
- `sshd -T` — dump full effective config (includes all defaults)
- `ssh -vvv user@host` — client-side verbose; shows handshake, key negotiation, auth steps

## WSL2-Specific Notes

### Port 22 conflict in bridged/mirrored networking

Our distro uses **bridged** networking (`networkingMode=bridged` in `.wslconfig`). The
Windows OpenSSH server (port 2222 via `win_ssh_port`) is separate, but port 22 on the
WSL distro's bridged IP is **independent** — no conflict as long as Windows sshd binds
to a different port.

However: during `apt install openssh-server`, Ubuntu 24.04's post-install script calls
`systemctl enable --now ssh.socket`. If systemd is not running at install time this
fails. With `systemd=true` in `/etc/wsl.conf` (our config), it succeeds.

### Installation via Ansible

The correct install task for our distro (post-cloud-init, systemd running):

```yaml
- name: Install openssh-server in WSL distro
  ansible.windows.win_shell: >-
    wsl -d {{ _wsl_distro }} -u root --
    apt-get install -y openssh-server
  register: _sshd_install
  changed_when: "'newly installed' in (_sshd_install.stdout | default(''))"

- name: Enable and start ssh.socket in WSL distro
  ansible.windows.win_shell: >-
    wsl -d {{ _wsl_distro }} -u root --
    systemctl enable --now ssh.socket
  register: _sshd_enable
  changed_when: "'Created symlink' in (_sshd_enable.stdout | default(''))"
```

### sshd_config drop-in for custom port (if needed)

If port 22 conflicts arise (e.g., another distro, future networking change):

```
/etc/ssh/sshd_config.d/99-wsl-port.conf
Port 2222
```

### Config file locations

| File | Purpose |
|------|---------|
| `/etc/ssh/sshd_config` | Main config (do not edit directly — use drop-ins) |
| `/etc/ssh/sshd_config.d/*.conf` | Drop-in overrides (preferred) |
| `/etc/ssh/ssh_host_*` | Host keys (generated at first install) |
| `/run/sshd.pid` | PID file when running |

---

# Execution Audit

Performed diagnostic-discovery research to identify where this component reports
operational and failure information.

Sources consulted:
- `https://manpages.ubuntu.com/manpages/jammy/en/man8/sshd.8.html` — authoritative sshd flags and log behaviour
- `https://askubuntu.com/questions/1512180` — Ubuntu 24.04 WSL2 install behaviour, socket activation, port conflict
- signoz.io/guides/ssh-logs — journald unit names, auth.log fallback, diagnostic commands
- Live distro state via `ansible win_shell → wsl -d Ubuntu-24.04` (2026-03-10)
