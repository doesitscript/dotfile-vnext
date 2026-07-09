ansible-galaxy collection install microsoft.hyperv
---
- name: Manage Hyper-V Virtual Machines
  hosts: hyperv_hosts
  gather_facts: false

    - name: Start the VM
        microsoft.hyperv.hv_vm_state:
            name: TestVM01
            state: running

            # hv_vm_state - VM power management (start, stop, pause, save, restart)
