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
The live state is fixed: HOM-LAB-HVH-02 now has 0.0.0.0/0 via 192.168.50.1, Windows can reach 1.1.1.1:443, and hom-lab-ctl-k3s-02 can curl Ubuntu successfully. I’m hardening that new task so a transient SSH drop during route installation doesn’t leave the playbook looking failed on the next run.

# can we group the playbooks so that we can get to this point next time
The Hyper-V side now converges cleanly with the explicit gateway/DNS in place. 

<-- right here>
I’m resuming the rebuild at the exact blocked step: fresh k3s-02 bootstrap, then the GPU and application playbooks if that lands.
#### end of grouping

**** new chapter ***
$ bin/codex-env ansible-playbook playbooks/deploy_gpu_infrastructure.yaml -i inventory/inventory.yaml
TASK [k3s_nvidia_device_plugin : Ensure NVIDIA device plugin Helm repository is configured] ***
TASK [k3s_nvidia_device_plugin : Ensure NVIDIA device plugin release is present] *** 

# need to add more of a timeout or something
^C[ERROR]: User interrupted execution
because this is exactly where the cluster starts advertising usable GPU resources.

```
NAMESPACE              NAME                                      READY   STATUS      RESTARTS   AGE     IP          NODE                 NOMINATED NODE   READINESS GATES
kube-system            coredns-796449bc5d-5dthm                  1/1     Running     0          3m53s   10.42.0.2   hom-lab-ctl-k3s-02   <none>           <none>
kube-system            helm-install-traefik-7g8dm                0/1     Completed   1          3m53s   10.42.0.5   hom-lab-ctl-k3s-02   <none>           <none>
kube-system            helm-install-traefik-crd-jq7zp            0/1     Completed   0          3m53s   10.42.0.6   hom-lab-ctl-k3s-02   <none>           <none>
kube-system            local-path-provisioner-5b5f758bcf-v2w6j   1/1     Running     0          3m53s   10.42.0.3   hom-lab-ctl-k3s-02   <none>           <none>
kube-system            metrics-server-564cb4ff68-hkc45           1/1     Running     0          3m53s   10.42.0.4   hom-lab-ctl-k3s-02   <none>           <none>
kube-system            traefik-79f8d498fd-88vnt                  1/1     Running     0          3m45s   10.42.0.7   hom-lab-ctl-k3s-02   <none>           <none>
nvidia-device-plugin   nvidia-device-plugin-nvr95                1/1     Running     0          3m1s    10.42.0.8   hom-lab-ctl-k3s-02   <none>           <none>
```

**The cluster itself already shows the NVIDIA device plugin pod running

Note  dealing with a hang
sudo k3s kubectl -n nvidia-device-plugin get ds nvidia-device-plugin -o yaml
*** false negative, ITS WORKING!!!
the device-plugin pod is already 1/1 Running, but the role waits through k8s_info wait_condition on the DaemonSet object, which appears to be stalling even after the DS is healthy.

'The cluster now advertises nvidia.com/gpu=1, and the NVIDIA device plugin is running, but the prereq gate is still correctly blocking because guest userspace is incomplete: nvidia-smi is still absent inside hom-lab-ctl-k3s-02. I’m correlating the owning GPU-P guest-runtime playbook so we can fix the missing userspace layer before attempting vllm.'
/The remaining gap is now well-bounded: deploy_gpu_infrastructure.yaml assumes the guest GPU-P userspace is already present, but that assumption isn’t encoded in the playbook order. I’m wiring hyperv_ubuntu_gpu_p_runtime.yaml into that playbook so future GPU infra runs bring up the guest runtime first instead of leaving nvidia-smi as an out-of-band prerequisite.'
Ensure this is documented
*** YEAH!!!
he missing userspace is fixed now: hyperv_ubuntu_gpu_p_linux_guest_runtime reached a clean nvidia-smi success inside hom-lab-ctl-k3s-02

#last command of non app layer:
bin/codex-env ansible-playbook playbooks/deploy_gpu_infrastructure.yaml -i inventory/inventory.yaml --syntax-check
#### form her it is the app layer: #####
after




starting with vllm, then langfuse, litellm, and Traefik publication.
bin/codex-env ansible-playbook playbooks/deploy_vllm_runtime.yaml -i inventory/inventory.yaml

### do we want to giv more CPU i think i have a lot
he vllm failure is just a sizing mismatch now: hom-lab-ctl-k3s-02 only has 2 allocatable CPU

# intial failure
langfuse: Helm chart fetch hit a DNS timeout resolving github.com from the guest
litellm: the role tries to create a secret in namespace litellm before ensuring that namespace exists

?The access chain refreshed the new k3s-02 kubeconfig, but the final per-cluster reachability check hit a TLS handshake timeout
nce I restarted the 26443 SSH tunnel, curl hit the K3s API and kubectl on k3s-02 worked immediately. I’m fixing the role so it treats “port is listening” and “API behind the tunnel is actually healthy” as two different things.


Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex 4 | Select-Object IPAddress,PrefixLength | ConvertTo-Json -Compress; Write-Host ---; Test-NetConnection 192.168.137.11 -Port 30189 | Select-Object ComputerName,RemotePort,TcpTestSucceeded | ConvertTo-Json -Compress; Write-Host ---; Test-NetConnection 192.168.137.11 -Port 30400 | Select-Object ComputerName,RemotePort,TcpTestSucceeded | ConvertTo-Json -Compress

sleep 8; bin/codex-env ssh HOM-LAB-HVH-02 "powershell -NoProfile -Command 'netsh interface portproxy show v4tov4; Write-Host ---; Test-NetConnection 192.168.137.11 -Port 30189 | Select-Object ComputerName,RemotePort,TcpTestSucceeded | ConvertTo-Json -Compress

make a skill to fix LAN edge


# Main fiexes:

The main fixes were in automation, not just live state. I updated playbooks/access.yaml to chain into mac hosts/kube surfaces, extended playbooks/deploy_gpu_infrastructure.yaml to continue through vllm -> langfuse -> litellm -> traefik -> k3s_mac_client, hardened k3s_mac_client so stale SSH tunnels are detected and refreshed, taught the Langfuse role to do a true fresh-install reset of its external Postgres DB, lowered Langfuse resource requests and disabled ClickHouse cluster mode for the single-node external ClickHouse path, fixed LiteLLM’s namespace/Helm ordering, and updated the vllm role to use a Recreate rollout bridge so request changes can converge on a one-GPU node. I also corrected the stale HOM-LAB-HVH-02 publish edge: 192.168.50.158:80 was still portproxying to retired Traefik NodePort 31461; it now points at the live 30189, and that’s why the bare langfuse.hom.lab / litellm.hom.lab URLs started working from mac.


# how can we automate or hook on this proces if it happens again:
. I also corrected the stale HOM-LAB-HVH-02 publish edge: 192.168.50.158:80 was still portproxying to retired Traefik NodePort 31461; it now points at the live 30189, and that’s why the bare langfuse.hom.lab / litellm.hom.lab URLs started working from mac.





#### the commit update ###
The main fixes were in automation, not just live state. I updated playbooks/access.yaml to chain into mac hosts/kube surfaces, extended playbooks/deploy_gpu_infrastructure.yaml to continue through vllm -> langfuse -> litellm -> traefik -> k3s_mac_client, hardened k3s_mac_client so stale SSH tunnels are detected and refreshed, taught the Langfuse role to do a true fresh-install reset of its external Postgres DB, lowered Langfuse resource requests and disabled ClickHouse cluster mode for the single-node external ClickHouse path, fixed LiteLLM’s namespace/Helm ordering, and updated the vllm role to use a Recreate rollout bridge so request changes can converge on a one-GPU node. I also corrected the stale HOM-LAB-HVH-02 publish edge: 192.168.50.158:80 was still portproxying to retired Traefik NodePort 31461; it now points at the live 30189, and that’s why the bare langfuse.hom.lab / litellm.hom.lab URLs started working from mac.
