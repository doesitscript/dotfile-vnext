# WinRM from macOS (control node)

Ansible’s WinRM/PSRP connection from **macOS** often fails due to a known Python/fork issue. It cannot be fixed inside Ansible. Set these before running playbooks that target Windows hosts:

```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes
export no_proxy=*
```

**Where to set them**

- **direnv**: project `.envrc` already contains these; run `direnv allow` in the repo.
- **Manual**: copy `.env.example` to `.env` and `source .env` (or add the exports to your bash profile: `~/.bash_profile` or `~/.bashrc` when working in this repo).

**Connection settings** for WinRM (transport, timeouts, NTLM) are in **`ansible.cfg`** in the repo root; the Mac uses that when connecting to Windows hosts.
