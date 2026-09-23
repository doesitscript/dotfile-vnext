# Managed application log paths

`managed_application_log_root` is the inventory contract for logs emitted by
configurable applications and tools that this project deliberately manages.

It is a root, not a complete log filename. Roles and playbooks should build
application-specific paths below it:

```text
<managed_application_log_root>/<application>/<file-or-subdirectory>
```

Examples:

```text
~/Library/Logs/<application>/ on the Mac controller
/var/log/dotfile-vnext/<application>/ on a Linux guest by default
%LOCALAPPDATA%\\dotfile-vnext\\logs\\<application>\\ on Windows by default
```

## Scope boundary

This contract does not redefine or relocate:

- Windows Event Logs or existing system-log storage;
- OpenSSH or other OS service logs;
- K3s pod logs;
- Docker/container logs;
- Loki or other shared infrastructure logging;
- vendor-native logs that the project does not configure.

Those surfaces retain their existing storage contracts. A host variable may
override `managed_application_log_root` when a dedicated external application
log location is commissioned, without changing system-log placement.

## Inventory ownership

The defaults are selected by inventory class:

| Inventory class | Default |
|---|---|
| `mac_dev` | `{{ ansible_env.HOME }}/Library/Logs` |
| `linux_vm_hosts` | `/var/log/dotfile-vnext` |
| `windows_os_hosts` | `%LOCALAPPDATA%\\dotfile-vnext\\logs` |

Host vars take precedence when a specific machine has a documented external
application-log root. A role must consume this contract explicitly; merely
defining the variable does not alter an application until that role opts in.

