ansible all -m ping -iinventory/inventory.yaml

[ERROR]: Task failed: ntlm: auth method ntlm requires a password

Task failed.
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

<<< caused by >>>

ntlm: auth method ntlm requires a password

server-225-win | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: ntlm: auth method ntlm requires a password",
    "unreachable": true
}
[ERROR]: Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname network-server-win: nodename nor servname provided, or not known                                                           

Task failed.
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

<<< caused by >>>

Failed to connect to the host via ssh: ssh: Could not resolve hostname network-server-win: nodename nor servname provided, or not known                                                                                 

network-server-win | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname network-server-win: nodename nor servname provided, or not known",                                                      
    "unreachable": true
}
[ERROR]: Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname dev-3090-win: nodename nor servname provided, or not known                                                                 

Task failed.
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

<<< caused by >>>

Failed to connect to the host via ssh: ssh: Could not resolve hostname dev-3090-win: nodename nor servname provided, or not known                                                                                       

dev-3090-win | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname dev-3090-win: nodename nor servname provided, or not known",                                                            
    "unreachable": true
}
[ERROR]: Task failed: Data could not be sent to remote host "network-server-wsl". Make sure this host can be reached over ssh: ssh: Could not resolve hostname network-server-wsl: nodename nor servname provided, or not known                                                                                                     
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

network-server-wsl | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Data could not be sent to remote host \"network-server-wsl\". Make sure this host can be reached over ssh: ssh: Could not resolve hostname network-server-wsl: nodename nor servname provided, or not known",                                                                                              
    "unreachable": true
}
[ERROR]: Task failed: Data could not be sent to remote host "dev-3090-wsl". Make sure this host can be reached over ssh: ssh: Could not resolve hostname dev-3090-wsl: nodename nor servname provided, or not known     
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

dev-3090-wsl | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Data could not be sent to remote host \"dev-3090-wsl\". Make sure this host can be reached over ssh: ssh: Could not resolve hostname dev-3090-wsl: nodename nor servname provided, or not known",                                                                                                          
    "unreachable": true
}
mac-dev | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
[ERROR]: Task failed: Data could not be sent to remote host "192.168.50.158". Make sure this host can be reached over ssh: ssh: connect to host 192.168.50.158 port 22: Operation timed out                             
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

server-225-wsl | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Data could not be sent to remote host \"192.168.50.158\". Make sure this host can be reached over ssh: ssh: connect to host 192.168.50.158 port 22: Operation timed out",
    "unreachable": true
}

---

## Diagnostics / Fixes

### server-225-win (WinRM) – "ntlm: auth method ntlm requires a password"
- **Cause:** Host vars had `win_password` but not `ansible_password` / `ansible_winrm_password`. The WinRM plugin needs one of those for NTLM. The fallback in `bin/fz` only runs when using `--limit server-225-win`, so `ansible all -m ping` never got a password.
- **Fix applied:** Added `ansible_password` and `ansible_winrm_password` (both `{{ win_password }}`) to `inventory/host_vars/server-225-win.yaml` and to `archives/bootstrap/local/templates/host_vars_windows.yml.j2`. Re-run ping with limit: `ansible all -m ping -i inventory/inventory.yaml --limit server_225` (or `--limit server-225-win,server-225-wsl`).

### server-225-wsl (SSH) – "connect to host 192.168.50.158 port 22: Operation timed out"
- **Cause:** From the Mac, nothing is accepting TCP on 192.168.50.158:22 (or the path is blocked). So either no SSH server is listening on the Windows host’s IP (e.g. Windows OpenSSH not installed/disabled, or WSL’s sshd not exposed on that IP), or a firewall is dropping port 22.
- **Fix (connectivity):** On server-225 (Windows): install/enable **OpenSSH Server**, ensure it listens on 0.0.0.0:22 (or the desired interface), and allow port 22 in Windows Firewall. If you intend to SSH into WSL, you may need a port forward (e.g. Windows 2222 → WSL:22) and then set `ansible_port: 2222` in `server-225-wsl` host_vars.
- **Fix (username/password prompt):** Use SSH key auth so Ansible doesn’t prompt: add your Mac’s public key to `~/.ssh/authorized_keys` for user `josh` on the target (WSL or Windows, depending on which you’re connecting to).