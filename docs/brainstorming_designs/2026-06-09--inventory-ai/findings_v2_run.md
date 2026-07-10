The guest still routes to the Hyper-V gateway, and it can ping 192.168.50.1, but it cannot reach 1.1.1.1 and I’m not seeing successful name resolution.

The resolver is actually healthy now: systemd-resolved is using 192.168.50.1, and archive.ubuntu.com resolves correctly. So the apt-cache failure is probably about repository transport

The resolver is actually healthy now: systemd-resolved is using 192.168.50.1, and archive.ubuntu.com resolves correctly. So the apt-cache failure is probably about repository transport or the apt metadata path rather than raw DNS

#TODO FIX
I found the concrete drift: HOM-LAB-HVH-02 has 192.168.50.158 on vEthernet (External), but its IPv4 default gateway is empty and the interface is no longer on DHCP. That explains the exact symptom set: LAN works, internet does not, and apt/image pulls time out.

I’ve got a repo-owned fix path: make the Hyper-V role able to converge the public IPv4 gateway/DNS when that surface is explicitly modeled, then turn it on for HOM-LAB-HVH-02. That keeps this as infrastructure state instead of a hand-edited Windows repair.

'$ bin/codex-env ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml -i inventory/inventory.yaml --syntax-check



playbook: playbooks/configure_hyperv_windows_hosts.yaml





Success'
'$ bin/codex-env ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml -i inventory/inventory.yaml --limit HOM-LAB-HVH-02



PLAY [Hyper-V Windows hosts - classify target hosts] ***************************

TASK [Classify Hyper-V Windows host lifecycle eligibility] *********************
ok: [HOM-LAB-HVH-02]

TASK [Derive runtime group for Hyper-V Windows hosts] **************************
ok: [HOM-LAB-HVH-02]

PLAY [Hyper-V Windows hosts - preview target selection] ************************

TASK [Preview Hyper-V Windows host selection] **********************************
ok: [HOM-LAB-HVH-02] => (item=HOM-LAB-HVH-02) => {
    "msg": {
        "adapter_description": "RZ608 Wi-Fi 6E 80MHz",
        "adapter_name": "Wi-Fi",
        "candidate": true,
        "external_switch_enabled": true,
        "guest_subnet": "192.168.137.0/24",
        "host": "HOM-LAB-HVH-02",
        "internal_switch_enabled": true,
        "reason": " eligible ",
        "runtime_requested": true,
        "selected": true,
        "state": "present",
        "switch_name": "External"
    }
}
ok: [HOM-LAB-HVH-02] => (item=HOM-LAB-HVH-01) => {
    "msg": {
        "adapter_description": "TP-Link Wi-Fi 6 PCIe Adapter",
        "adapter_name": "Wi-Fi",
        "candidate": false,
        "external_switch_enabled": true,
        "guest_subnet": "192.168.138.0/24",
        "host": "HOM-LAB-HVH-01",
        "internal_switch_enabled": true,
        "reason": "not classified",
        "runtime_requested": false,
        "selected": false,
        "state": "present",
        "switch_name": "External"
    }
}

PLAY [Hyper-V Windows hosts - live LAN publish preview] ************************

TASK [Preview live Hyper-V LAN publish surface] ********************************
included: hyperv_networking for HOM-LAB-HVH-02

TASK [hyperv_networking : Resolve hyperv_config contract for preview] **********
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Probe published port surface during Hyper-V preview] ***
included: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/published_port_surface_probe.yml for HOM-LAB-HVH-02

TASK [hyperv_networking : Probe live Hyper-V LAN publish surface] **************
ok: [HOM-LAB-HVH-02]

PLAY [Hyper-V Windows hosts - lifecycle] ***************************************

TASK [Ensure Hyper-V Windows host infrastructure is in the requested lifecycle state] ***
included: hyperv_networking for HOM-LAB-HVH-02

TASK [hyperv_networking : Resolve hyperv_config contract] **********************
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Determine whether Hyper-V networking changes are requested] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Prepare Hyper-V management OS boot recovery] *********
included: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/management_os_boot_recovery_prepare.yml for HOM-LAB-HVH-02

TASK [hyperv_networking : Validate Hyper-V management OS boot recovery state] ***
ok: [HOM-LAB-HVH-02] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [hyperv_networking : Require host_ip when Hyper-V management OS boot recovery is enabled] ***
ok: [HOM-LAB-HVH-02] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [hyperv_networking : Ensure Hyper-V management OS recovery directories exist] ***
ok: [HOM-LAB-HVH-02] => (item=C:\ProgramData\Ansible\hyperv_networking)
ok: [HOM-LAB-HVH-02] => (item=C:\ProgramData\Ansible\hyperv_networking\scripts)
ok: [HOM-LAB-HVH-02] => (item=C:\ProgramData\Ansible\hyperv_networking\logs)

TASK [hyperv_networking : Stage Hyper-V management OS boot recovery script] ****
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Register Hyper-V management OS boot recovery scheduled task] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Create External Virtual Switch] **********************
included: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/networking.yml for HOM-LAB-HVH-02

TASK [hyperv_networking : Probe External VMSwitch state and resolve external adapter selection] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Re-probe External VMSwitch state after create path] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Require External VMSwitch to exist after Hyper-V networking] ***
ok: [HOM-LAB-HVH-02] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [hyperv_networking : Create Internal Hyper-V guest switch and ICS sharing pair] ***
included: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/internal_ics.yml for HOM-LAB-HVH-02

TASK [hyperv_networking : Probe Internal VMSwitch state] ***********************
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Re-probe Internal VMSwitch state after create path] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Require Internal VMSwitch to exist after Hyper-V guest networking] ***
ok: [HOM-LAB-HVH-02] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [hyperv_networking : Probe PSInternetConnectionSharing module before disabling ICS] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Disable Internet Connection Sharing when routed guest access should stay direct] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Enable routed private-subnet access for the Hyper-V guest network] ***
included: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/routed_private_subnet.yml for HOM-LAB-HVH-02

TASK [hyperv_networking : Persist Windows IP router posture for routed guest subnet mode] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Ensure guest gateway IP and IPv4 forwarding are enabled for routed guest subnet mode] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Ensure host-side outbound NAT is absent when direct routed guest access is desired] ***
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Probe live publish surface before guest published TCP convergence] ***
included: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/published_port_surface_probe.yml for HOM-LAB-HVH-02

TASK [hyperv_networking : Probe live Hyper-V LAN publish surface] **************
ok: [HOM-LAB-HVH-02]

TASK [hyperv_networking : Ensure modeled public IPv4 gateway and DNS exist on the public interface] ***
[ERROR]: Task failed: Data could not be sent to remote host "192.168.50.158". Make sure this host can be reached over ssh: #< CLIXML
Origin: /Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/routed_private_subnet.yml:303:3

301       }}
302
303 - name: Ensure modeled public IPv4 gateway and DNS exist on the public interface
      ^ column 3

fatal: [HOM-LAB-HVH-02]: UNREACHABLE! => {"changed": false, "msg": "Task failed: Data could not be sent to remote host \"192.168.50.158\". Make sure this host can be reached over ssh: #< CLIXML", "unreachable": true}

PLAY RECAP *********************************************************************
HOM-LAB-HVH-02             : ok=32   changed=0    unreachable=1'<>

** Validating test **
ssh -o BatchMode=yes -o ConnectTimeout=10 HOM-LAB-HVH-02 "hostname; powershell -NoProfile -Command "Get-NetIPConfiguration -InterfaceAlias 'vEthernet (External)' | Format-List InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer; Get-NetRoute -AddressFamily IPv4 | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Format-Table ifIndex,InterfaceAlias,NextHop,RouteMetric,State -Auto; Test-NetConnection -ComputerName 1.1.1.1 -Port 443 | Format-List ComputerName,RemotePort,TcpTestSucceeded,InterfaceAlias,SourceAddress


HOM-LAB-HVH-02


InterfaceAlias     : vEthernet (External)
IPv4Address        : {192.168.50.158}
IPv4DefaultGateway : {MSFT_NetRoute (InstanceID = ":8:8:8:9:55?55;C?8;@B8?:8;55;")}
DNSServer          : {MSFT_DNSClientServerAddress (Name = "4", CreationClassName = "", 
                     SystemCreationClassName = "", SystemName = "23"), 
                     MSFT_DNSClientServerAddress (Name = "4", CreationClassName = "", 
                     SystemCreationClassName = "", SystemName = "2")}




ifIndex InterfaceAlias       NextHop      RouteMetric State
------- --------------       -------      ----------- -----
      4 vEthernet (External) 192.168.50.1         256 Alive




ComputerName     : 1.1.1.1
RemotePort       : 443
TcpTestSucceeded : True
InterfaceAlias   : vEthernet (External)
SourceAddress    : 192.168.50.158'

ssh -J HOM-LAB-HVH-02 -i ~/.ssh/id_ed25519_ansible -o IdentitiesOnly=yes -o StrictHostKeyChecking=no joshc@192.168.137.11 "timeout 8 curl -I -4 http://archive.ubuntu.com/ubuntu/; echo rc:$?


  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
Date: Fri, 10 Jul 2026 01:04:54 GMT
Server: Apache/2.4.52 (Ubuntu)
Content-Type: text/html;charset=UTF-8
