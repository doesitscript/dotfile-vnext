

TASK [access_identity_windows : DEBUG OUTPUT: Log locations and sources] *************
ok: [server-225-win] => {
    "msg": "╔══════════════════════════════════════════════════════════════╗\n║              LOG LOCATIONS & DATA SOURCES                   ║\n╠══════════════════════════════════════════════════════════════╣\n║ WINDOWS HOST (server-225-win)                     ║\n║  • WinRM Event Log:    Microsoft-Windows-WinRM/Operational  ║\n║  • OpenSSH Operational: OpenSSH/Operational                 ║\n║  • OpenSSH Admin:       OpenSSH/Admin                      ║\n║  • sshd_config:         C:\\ProgramData\\ssh\\sshd_config     ║\n║  • SSH log dir:         C:\\ProgramData\\ssh\\logs\\           ║\n║  • System log:          System (WinRM, Hyper-V, TCPIP)     ║\n║  • Application log:     Application (sshd provider)        ║\n╠══════════════════════════════════════════════════════════════╣\n║ WSL (Ubuntu-24.04)                   ║\n║  • Auth log:            /var/log/auth.log                  ║\n║  • sshd_config:         /etc/ssh/sshd_config               ║\n║  • sshd journal:        journalctl -u ssh                  ║\n║  • Netplan config:      /etc/netplan/*.yaml                ║\n║  • DNS:                 /etc/resolv.conf + resolvectl      ║\n║  • Network:             ip addr / ip route                 ║\n╠══════════════════════════════════════════════════════════════╣\n║ MAC CONTROLLER                                              ║\n║  • SSH client config:   ~/.ssh/config                      ║\n║  • SSH mux sockets:     ~/.ssh/ssh_mux_*                   ║\n║  • Ansible log:         (stdout / callback plugin)         ║\n╚══════════════════════════════════════════════════════════════╝\n"
}

TASK [access_identity_windows : DEBUG OUTPUT: Windows OpenSSH — service and config] ***
ok: [server-225-win] => {
    "_debug_win_ssh.result": {
        "ssh_log_files": [],
        "sshd_config": "# This is the sshd server system-wide configuration file.  See\r\n# sshd_config(5) for more information.\r\n\r\n# The strategy used for options in the default sshd_config shipped with\r\n# OpenSSH is to specify options with their default value where\r\n# possible, but leave them commented.  Uncommented options override the\r\n# default value.\r\n\r\nPort 2222\r\nPort 2223\r\n#AddressFamily any\r\n#ListenAddress 0.0.0.0\r\n#ListenAddress ::\r\n\r\n#HostKey __PROGRAMDATA__/ssh/ssh_host_rsa_key\r\n#HostKey __PROGRAMDATA__/ssh/ssh_host_dsa_key\r\n#HostKey __PROGRAMDATA__/ssh/ssh_host_ecdsa_key\r\n#HostKey __PROGRAMDATA__/ssh/ssh_host_ed25519_key\r\n\r\n# Ciphers and keying\r\n#RekeyLimit default none\r\n\r\n# Logging\r\n#SyslogFacility AUTH\r\n#LogLevel INFO\r\n\r\n# Authentication:\r\n\r\n#LoginGraceTime 2m\r\n#PermitRootLogin prohibit-password\r\n#StrictModes yes\r\n#MaxAuthTries 6\r\n#MaxSessions 10\r\n\r\n#PubkeyAuthentication yes\r\n\r\n# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2\r\n# but this is overridden so installations will only check .ssh/authorized_keys\r\nAuthorizedKeysFile\t.ssh/authorized_keys\r\n\r\n#AuthorizedPrincipalsFile none\r\n\r\n# For this to work you will also need host keys in %programData%/ssh/ssh_known_hosts\r\n#HostbasedAuthentication no\r\n# Change to yes if you don't trust ~/.ssh/known_hosts for\r\n# HostbasedAuthentication\r\n#IgnoreUserKnownHosts no\r\n# Don't read the user's ~/.rhosts and ~/.shosts files\r\n#IgnoreRhosts yes\r\n\r\n# To disable tunneled clear text passwords, change to no here!\r\n#PasswordAuthentication yes\r\n#PermitEmptyPasswords no\r\n\r\n# GSSAPI options\r\n#GSSAPIAuthentication no\r\n\r\n#AllowAgentForwarding yes\r\n#AllowTcpForwarding yes\r\n#GatewayPorts no\r\n#PermitTTY yes\r\n#PrintMotd yes\r\n#PrintLastLog yes\r\n#TCPKeepAlive yes\r\n#UseLogin no\r\n#PermitUserEnvironment no\r\nClientAliveInterval 60\r\nClientAliveCountMax 3\r\n#UseDNS no\r\n#PidFile /var/run/sshd.pid\r\n#MaxStartups 10:30:100\r\n#PermitTunnel no\r\n#ChrootDirectory none\r\n#VersionAddendum none\r\n\r\n# no default banner path\r\n#Banner none\r\n\r\n# override default of no subsystems\r\nSubsystem\tsftp\tsftp-server.exe\r\n\r\nAllowGroups administrators \"openssh users\"\r\n\r\n# Example of overriding settings on a per-user basis\r\n#Match User anoncvs\r\n#\tAllowTcpForwarding no\r\n#\tPermitTTY no\r\n#\tForceCommand cvs server\r\n\r\nMatch Group administrators\r\n       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys\r\n\r\nMatch LocalPort 2223\r\n    ForceCommand powershell.exe -NoLogo -NoProfile\r\n",
        "sshd_config_path": "C:\\ProgramData\\ssh\\sshd_config",
        "sshd_processes": [
            {
                "cpu": 0.34375,
                "mem_bytes": 11968512,
                "pid": 12884,
                "started": "02/22/2026 00:37:18"
            },
            {
                "cpu": 0.03125,
                "mem_bytes": 11571200,
                "pid": 24080,
                "started": "02/21/2026 21:23:38"
            },
            {
                "cpu": 0.015625,
                "mem_bytes": 11886592,
                "pid": 27160,
                "started": "02/22/2026 00:37:18"
            }
        ],
        "sshd_service": {
            "startType": "Automatic",
            "status": "Running"
        }
    }
}

TASK [access_identity_windows : DEBUG OUTPUT: Windows OpenSSH — event log entries] ***
ok: [server-225-win] => {
    "_debug_win_ssh_events.result": {
        "admin": [
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:40"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:40"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:40"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:39"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:39"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:39"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:38"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:38"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:37"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:37"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:35"
            },
            {
                "id": 2,
                "level": "Error",
                "msg": "sshd: error: no more sessions",
                "time": "02/20/2026 18:07:33"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: mm_log_handler: write: Unknown error",
                "time": "02/20/2026 05:28:59"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 50961",
                "time": "02/20/2026 05:20:59"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: mm_log_handler: write: Unknown error",
                "time": "02/20/2026 05:06:09"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 50557",
                "time": "02/20/2026 05:05:38"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: mm_log_handler: write: Unknown error",
                "time": "02/20/2026 04:55:48"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 50364",
                "time": "02/20/2026 04:53:58"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: mm_log_handler: write: Unknown error",
                "time": "02/15/2026 23:18:29"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 53590",
                "time": "02/15/2026 23:17:16"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: mm_log_handler: write: Unknown error",
                "time": "02/15/2026 19:25:08"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 50858",
                "time": "02/15/2026 19:24:43"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: mm_log_handler: write: Unknown error",
                "time": "02/15/2026 19:19:22"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 50691",
                "time": "02/15/2026 19:09:44"
            },
            {
                "id": 1,
                "level": "Critical",
                "msg": "sshd: fatal: Timeout before authentication for 192.168.50.33 port 50349",
                "time": "02/15/2026 18:38:00"
            }
        ],
        "operational": [
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Disconnected from 192.168.50.33 port 58205",
                "time": "02/22/2026 00:42:57"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Received disconnect from 192.168.50.33 port 58205:11: disconnected by user",
                "time": "02/22/2026 00:42:57"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 58398 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/22/2026 00:37:18"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 58205 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/22/2026 00:32:49"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on 0.0.0.0 port 2222.",
                "time": "02/21/2026 21:23:38"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on :: port 2222.",
                "time": "02/21/2026 21:23:38"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on 0.0.0.0 port 2223.",
                "time": "02/21/2026 21:23:38"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on :: port 2223.",
                "time": "02/21/2026 21:23:38"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Disconnected from 192.168.50.33 port 60518",
                "time": "02/21/2026 20:14:29"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Received disconnect from 192.168.50.33 port 60518:11: disconnected by user",
                "time": "02/21/2026 20:14:29"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 60518 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/21/2026 20:14:29"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 60410 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/21/2026 20:11:55"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 59511 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/21/2026 19:51:04"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 59494 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/21/2026 19:50:34"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 59353 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/21/2026 19:47:14"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on 0.0.0.0 port 2222.",
                "time": "02/21/2026 18:08:48"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on :: port 2222.",
                "time": "02/21/2026 18:08:48"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on 0.0.0.0 port 2223.",
                "time": "02/21/2026 18:08:48"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Server listening on :: port 2223.",
                "time": "02/21/2026 18:08:48"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Received signal 8; terminating.",
                "time": "02/21/2026 18:08:14"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Disconnected from 192.168.50.33 port 63920",
                "time": "02/21/2026 10:20:50"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Received disconnect from 192.168.50.33 port 63920:11: disconnected by user",
                "time": "02/21/2026 10:20:50"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Disconnected from 192.168.50.33 port 63919",
                "time": "02/21/2026 10:20:37"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Received disconnect from 192.168.50.33 port 63919:11: disconnected by user",
                "time": "02/21/2026 10:20:37"
            },
            {
                "id": 4,
                "level": "Information",
                "msg": "sshd: Accepted publickey for joshc from 192.168.50.33 port 63920 ssh2: ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow",
                "time": "02/21/2026 10:10:37"
            }
        ]
    }
}

TASK [access_identity_windows : DEBUG OUTPUT: WinRM state and sessions] **************
ok: [server-225-win] => {
    "_debug_winrm.result": {
        "active_shell_count": 4,
        "active_shells": [
            {
                "clientIP": "192.168.50.33",
                "idleTimeout": "PT7200.000S",
                "inactivity": "P0DT0H55M59S",
                "owner": "DESKTOP-VLLM\\joshc",
                "runTime": "P0DT0H55M59S",
                "shellId": "921DC100-A95B-4F92-A8FE-C7897A01D1C6"
            },
            {
                "clientIP": "192.168.50.33",
                "idleTimeout": "PT7200.000S",
                "inactivity": "P0DT0H0M0S",
                "owner": "DESKTOP-VLLM\\joshc",
                "runTime": "P0DT0H0M1S",
                "shellId": "899E302B-3D3D-49D5-99F2-05A9EA4074C8"
            },
            {
                "clientIP": "192.168.50.33",
                "idleTimeout": "PT7200.000S",
                "inactivity": "P0DT0H56M41S",
                "owner": "DESKTOP-VLLM\\joshc",
                "runTime": "P0DT0H56M42S",
                "shellId": "C6CB3919-7F8F-47CF-83F9-DEE1A4E81F9F"
            },
            {
                "clientIP": "192.168.50.33",
                "idleTimeout": "PT7200.000S",
                "inactivity": "P0DT0H3M17S",
                "owner": "DESKTOP-VLLM\\joshc",
                "runTime": "P0DT0H3M17S",
                "shellId": "89550338-026F-4D81-8F2D-5CEC83D8406E"
            }
        ],
        "winrm_events_note": "No WinRM warnings/errors in System log (last 6h)",
        "winrm_listener": "Listener\r\n    Address = *\r\n    Transport = HTTP\r\n    Port = 5985\r\n    Hostname\r\n    Enabled = true\r\n    URLPrefix = wsman\r\n    CertificateThumbprint\r\n    ListeningOn = 127.0.0.1, 169.254.58.91, 169.254.107.214, 169.254.236.114, 192.168.50.158, ::1, 2600:1700:48fd:800f:bcbd:c83a:6612:ebb1, fdfa:7038:521c:a5fa:7c9:f4a1:90b8:1b1e, fe80::6657:23c:bf4c:fd7c%9, fe80::aad6:cbde:b4fa:ee3e%20, fe80::b72d:8ea:af35:7491%15, fe80::c667:8936:ced9:48df%14",
        "winrm_service": {
            "startType": "Automatic",
            "status": "Running"
        },
        "winrm_system_events": []
    }
}

TASK [access_identity_windows : DEBUG OUTPUT: Windows network state] *****************
ok: [server-225-win] => {
    "_debug_network.result": {
        "adapters": [
            {
                "desc": "Hyper-V Virtual Ethernet Adapter",
                "mac": "B4-B5-B6-94-5A-BD",
                "name": "vEthernet (WSL-Bridge)",
                "speed": "1.2 Gbps",
                "status": "Up"
            },
            {
                "desc": "Realtek Gaming 2.5GbE Family Controller",
                "mac": "04-42-1A-E7-D1-2D",
                "name": "Ethernet",
                "speed": "0 bps",
                "status": "Disconnected"
            },
            {
                "desc": "RZ608 Wi-Fi 6E 80MHz",
                "mac": "B4-B5-B6-94-5A-BD",
                "name": "Wi-Fi",
                "speed": "1.2 Gbps",
                "status": "Up"
            },
            {
                "desc": "Microsoft Network Adapter Multiplexor Driver",
                "mac": "B4-B5-B6-94-5A-BD",
                "name": "Network Bridge",
                "speed": "1.2 Gbps",
                "status": "Up"
            }
        ],
        "firewall_ssh_winrm": [
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "Windows Remote Management (HTTP-In)",
                "profile": "Domain, Private"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "Windows Remote Management (HTTP-In)",
                "profile": "Public"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "OpenSSH SSH Server (sshd)",
                "profile": "Private"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "WinRM HTTPS 5986",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "OpenSSH Server (Port 22)",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "WinRM-HTTPS",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "sshd",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "Windows Remote Management (HTTP-In)",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "WinRM-HTTP-In-TCP",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "sshd-Server-In-TCP",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "sshd-PowerShell-In-TCP",
                "profile": "Any"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "name": "sshd-WSL-Direct-In-TCP",
                "profile": "Any"
            }
        ],
        "hyperv_fw": [
            {
                "action": "Allow",
                "direction": "Inbound",
                "enabled": 1,
                "name": "Allow inbound SSH to WSL (TCP 22)"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "enabled": 1,
                "name": "WslCore Inbound ICMPv4 Default Allow Rule"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "enabled": 1,
                "name": "WslCore Inbound ICMPv6 Default Allow Rule"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "enabled": 1,
                "name": "WslCore Inbound IPv4 mDNS Default Allow Rule"
            },
            {
                "action": "Allow",
                "direction": "Inbound",
                "enabled": 1,
                "name": "WslCore Inbound IPv6 mDNS Default Allow Rule"
            }
        ],
        "ipv4": [
            {
                "iface": "vEthernet (WSL-Bridge)",
                "ip": "192.168.50.158",
                "origin": "Dhcp",
                "prefix": 24
            },
            {
                "iface": "Local Area Connection* 2",
                "ip": "169.254.107.214",
                "origin": "WellKnown",
                "prefix": 16
            },
            {
                "iface": "Local Area Connection* 1",
                "ip": "169.254.58.91",
                "origin": "WellKnown",
                "prefix": 16
            },
            {
                "iface": "Ethernet",
                "ip": "169.254.236.114",
                "origin": "WellKnown",
                "prefix": 16
            },
            {
                "iface": "Loopback Pseudo-Interface 1",
                "ip": "127.0.0.1",
                "origin": "WellKnown",
                "prefix": 8
            }
        ],
        "network_system_events": [
            {
                "id": 1014,
                "level": "Warning",
                "msg": "Name resolution for the name api3.cursor.sh timed out after none of the configured DNS servers responded. Client PID 23564.",
                "provider": "Microsoft-Windows-DNS-Client",
                "time": "02/22/2026 00:14:38"
            },
            {
                "id": 1014,
                "level": "Warning",
                "msg": "Name resolution for the name api3.cursor.sh timed out after none of the configured DNS servers responded. Client PID 23564.",
                "provider": "Microsoft-Windows-DNS-Client",
                "time": "02/22/2026 00:14:25"
            },
            {
                "id": 1014,
                "level": "Warning",
                "msg": "Name resolution for the name ws.chatgpt.com timed out after none of the configured DNS servers responded. Client PID 23632.",
                "provider": "Microsoft-Windows-DNS-Client",
                "time": "02/22/2026 00:12:55"
            },
            {
                "id": 22,
                "level": "Warning",
                "msg": "Media disconnected on NIC /DEVICE/{144AB7BE-FE3A-4F60-931C-26D4511CBD52} (Friendly Name: Microsoft Network Adapter Multiplexor Driver).",
                "provider": "Microsoft-Windows-Hyper-V-VmSwitch",
                "time": "02/22/2026 00:12:50"
            },
            {
                "id": 1014,
                "level": "Warning",
                "msg": "Name resolution for the name api.steampowered.com timed out after none of the configured DNS servers responded. Client PID 16260.",
                "provider": "Microsoft-Windows-DNS-Client",
                "time": "02/22/2026 00:12:39"
            },
            {
                "id": 22,
                "level": "Warning",
                "msg": "Media disconnected on NIC /DEVICE/{144AB7BE-FE3A-4F60-931C-26D4511CBD52} (Friendly Name: Microsoft Network Adapter Multiplexor Driver).",
                "provider": "Microsoft-Windows-Hyper-V-VmSwitch",
                "time": "02/22/2026 00:10:25"
            },
            {
                "id": 1014,
                "level": "Warning",
                "msg": "Name resolution for the name wsl.localhost timed out after none of the configured DNS servers responded. Client PID 3164.",
                "provider": "Microsoft-Windows-DNS-Client",
                "time": "02/21/2026 21:24:28"
            }
        ]
    }
}

TASK [access_identity_windows : DEBUG OUTPUT: WSL sshd and networking] ***************
ok: [server-225-win] => {
    "_debug_wsl.result": {
        "auth_log_tail": "2026-02-21T21:31:34.721292-06:00 DESKTOP-VLLM systemd-logind[192]: New seat seat0.\n2026-02-21T21:31:38.115553-06:00 DESKTOP-VLLM login[413]: PAM unable to dlopen(pam_lastlog.so): /usr/lib/security/pam_lastlog.so: cannot open shared object file: No such file or directory\n2026-02-21T21:31:38.115668-06:00 DESKTOP-VLLM login[413]: PAM adding faulty module: pam_lastlog.so\n2026-02-21T21:31:38.542258-06:00 DESKTOP-VLLM login[413]: pam_unix(login:session): session opened for user root(uid=0) by root(uid=0)\n2026-02-21T21:31:38.642522-06:00 DESKTOP-VLLM systemd-logind[192]: New session 1 of user root.\n2026-02-21T21:31:38.662737-06:00 DESKTOP-VLLM (systemd): pam_unix(systemd-user:session): session opened for user root(uid=0) by root(uid=0)\n2026-02-21T21:31:38.843848-06:00 DESKTOP-VLLM login[479]: ROOT LOGIN  on '/dev/pts/1'\n2026-02-21T21:31:48.994946-06:00 DESKTOP-VLLM systemd-logind[192]: The system will power off now!\n2026-02-21T21:31:49.009584-06:00 DESKTOP-VLLM systemd-logind[192]: System is powering down.\n2026-02-21T21:32:03.341055-06:00 DESKTOP-VLLM useradd[215]: new group: name=joshc, GID=1000\n2026-02-21T21:32:03.341061-06:00 DESKTOP-VLLM useradd[215]: new user: name=joshc, UID=1000, GID=1000, home=/home/joshc, shell=/bin/bash, from=none\n2026-02-21T21:32:03.341118-06:00 DESKTOP-VLLM useradd[215]: add 'joshc' to group 'adm'\n2026-02-21T21:32:03.341125-06:00 DESKTOP-VLLM useradd[215]: add 'joshc' to group 'sudo'\n2026-02-21T21:32:03.341129-06:00 DESKTOP-VLLM useradd[215]: add 'joshc' to shadow group 'adm'\n2026-02-21T21:32:03.341134-06:00 DESKTOP-VLLM useradd[215]: add 'joshc' to shadow group 'sudo'\n2026-02-21T21:32:03.341140-06:00 DESKTOP-VLLM passwd[226]: password for 'joshc' changed by 'root'\n2026-02-21T21:32:03.341823-06:00 DESKTOP-VLLM systemd-logind[253]: New seat seat0.\n2026-02-21T21:32:04.427463-06:00 DESKTOP-VLLM login[418]: PAM unable to dlopen(pam_lastlog.so): /usr/lib/security/pam_lastlog.so: cannot open shared object file: No such file or directory\n2026-02-21T21:32:04.427579-06:00 DESKTOP-VLLM login[418]: PAM adding faulty module: pam_lastlog.so\n2026-02-21T21:32:04.470754-06:00 DESKTOP-VLLM login[418]: pam_unix(login:session): session opened for user root(uid=0) by root(uid=0)\n2026-02-21T21:32:04.532923-06:00 DESKTOP-VLLM systemd-logind[253]: New session 1 of user root.\n2026-02-21T21:32:04.546196-06:00 DESKTOP-VLLM (systemd): pam_unix(systemd-user:session): session opened for user root(uid=0) by root(uid=0)\n2026-02-21T21:32:04.727890-06:00 DESKTOP-VLLM login[483]: ROOT LOGIN  on '/dev/pts/1'\n2026-02-21T21:32:47.693828-06:00 DESKTOP-VLLM polkitd[764]: Loading rules from directory /etc/polkit-1/rules.d\n2026-02-21T21:32:47.694021-06:00 DESKTOP-VLLM polkitd[764]: Loading rules from directory /usr/share/polkit-1/rules.d\n2026-02-21T21:32:47.695514-06:00 DESKTOP-VLLM polkitd[764]: Finished loading, compiling and executing 4 rules\n2026-02-21T21:32:47.696181-06:00 DESKTOP-VLLM polkitd[764]: Acquired the name org.freedesktop.PolicyKit1 on the system bus\n2026-02-21T21:33:57.126367-06:00 DESKTOP-VLLM systemd-logind[253]: The system will power off now!\n2026-02-21T21:33:57.137388-06:00 DESKTOP-VLLM systemd-logind[253]: System is powering down.",
        "dns_config": "nameserver 192.168.50.1\n---\nsd_bus_open_system: No such file or directory\nnot: line 1: systemd-resolve: command not found\nresolvectl",
        "flush_eth0_service": "enabled\nSystem has not been booted with systemd as init system (PID 1). Can't operate.\nFailed to connect to bus: Host is down\nService",
        "ip_addresses": "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000\n    inet 127.0.0.1/8 scope host lo\n       valid_lft forever preferred_lft forever\n2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000\n    inet 192.168.50.158/24 brd 192.168.50.255 scope global eth0\n       valid_lft forever preferred_lft forever",
        "netplan": "network:\n  version: 2\n  ethernets:\n    eth0:\n      dhcp4: false\n      addresses:\n        - 192.168.50.222/24\n      routes:\n        - to: default\n          via: 192.168.50.1\n      nameservers:\n        addresses:\n          - 192.168.50.1",
        "networkd_status": "System has not been booted with systemd as init system (PID 1). Can't operate.\nFailed to connect to bus: Host is down\nFailed to connect to system bus: No such file or directory\nnetworkctl",
        "routes": "default via 192.168.50.1 dev eth0 \n192.168.50.0/24 dev eth0 proto kernel scope link src 192.168.50.158",
        "ssh_socket": "masked\nSystem has not been booted with systemd as init system (PID 1). Can't operate.\nFailed to connect to bus: Host is down",
        "sshd_config": "# This is the sshd server system-wide configuration file.  See\n# sshd_config(5) for more information.\n# This sshd was compiled with PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games\n# The strategy used for options in the default sshd_config shipped with\n# OpenSSH is to specify options with their default value where\n# possible, but leave them commented.  Uncommented options override the\n# default value.\nInclude /etc/ssh/sshd_config.d/*.conf\n# When systemd socket activation is used (the default), the socket\n# configuration must be re-generated after changing Port, AddressFamily, or\n# ListenAddress.\n#\n# For changes to take effect, run:\n#\n#   systemctl daemon-reload\n#   systemctl restart ssh.socket\n#\n#AddressFamily any\n#HostKey /etc/ssh/ssh_host_rsa_key\n#HostKey /etc/ssh/ssh_host_ecdsa_key\n#HostKey /etc/ssh/ssh_host_ed25519_key\n# Ciphers and keying\n#RekeyLimit default none\n# Logging\n#SyslogFacility AUTH\n#LogLevel INFO\n# Authentication:\n#LoginGraceTime 2m\n#PermitRootLogin prohibit-password\n#StrictModes yes\n#MaxAuthTries 6\n#MaxSessions 10\n# Expect .ssh/authorized_keys2 to be disregarded by default in future.\n#AuthorizedKeysFile\t.ssh/authorized_keys .ssh/authorized_keys2\n#AuthorizedPrincipalsFile none\n#AuthorizedKeysCommand none\n#AuthorizedKeysCommandUser nobody\n# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts\n#HostbasedAuthentication no\n# Change to yes if you don't trust ~/.ssh/known_hosts for\n# HostbasedAuthentication\n#IgnoreUserKnownHosts no\n# Don't read the user's ~/.rhosts and ~/.shosts files\n#IgnoreRhosts yes\n# To disable tunneled clear text passwords, change to no here!\n#PermitEmptyPasswords no\n# Change to yes to enable challenge-response passwords (beware issues with\n# some PAM modules and threads)\nKbdInteractiveAuthentication no\n# Kerberos options\n#KerberosAuthentication no\n#KerberosOrLocalPasswd yes\n#KerberosTicketCleanup yes\n#KerberosGetAFSToken no\n# GSSAPI options\n#GSSAPIAuthentication no\n#GSSAPICleanupCredentials yes\n#GSSAPIStrictAcceptorCheck yes\n#GSSAPIKeyExchange no\n# Set this to 'yes' to enable PAM authentication, account processing,\n# and session processing. If this is enabled, PAM authentication will\n# be allowed through the KbdInteractiveAuthentication and\n# PasswordAuthentication.  Depending on your PAM configuration,\n# PAM authentication via KbdInteractiveAuthentication may bypass\n# the setting of \"PermitRootLogin prohibit-password\".\n# If you just want the PAM account and session checks to run without\n# PAM authentication, then enable this but set PasswordAuthentication\n# and KbdInteractiveAuthentication to 'no'.\nUsePAM yes\n#AllowAgentForwarding yes\n#AllowTcpForwarding yes\n#GatewayPorts no\nX11Forwarding yes\n#X11DisplayOffset 10\n#X11UseLocalhost yes\n#PermitTTY yes\nPrintMotd no\n#PrintLastLog yes\n#TCPKeepAlive yes\n#PermitUserEnvironment no\n#Compression delayed\n#UseDNS no\n#PidFile /run/sshd.pid\n#MaxStartups 10:30:100\n#PermitTunnel no\n#ChrootDirectory none\n#VersionAddendum none\n# no default banner path\n#Banner none\n# Allow client to pass locale environment variables\nAcceptEnv LANG LC_*\n# override default of no subsystems\nSubsystem\tsftp\t/usr/lib/openssh/sftp-server\n# Example of overriding settings on a per-user basis\n#Match User anoncvs\n#\tX11Forwarding no\n#\tAllowTcpForwarding no\n#\tPermitTTY no\n#\tForceCommand cvs server\nPort 22\nPubkeyAuthentication yes\nClientAliveCountMax 3\nClientAliveInterval 60\nListenAddress 0.0.0.0\nPasswordAuthentication yes",
        "sshd_journal": "-- No entries --",
        "sshd_status": "System has not been booted with systemd as init system (PID 1). Can't operate.\nFailed to connect to bus: Host is down\n---\nSystem has not been booted with systemd as init system (PID 1). Can't operate.\nFailed to connect to bus: Host is down",
        "wsl_list": "NAME            STATE           VERSION\n* Ubuntu-24.04    Running         2"
    }
}

PLAY RECAP ***************************************************************************
server-225-win             : ok=80   changed=9    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   

(.venv) Joshs-MacBook-Pro:dotfile-vnext joshc$ 