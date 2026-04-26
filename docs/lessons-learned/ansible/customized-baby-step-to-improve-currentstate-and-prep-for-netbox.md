That looks like “enterprise-ish Ansible,” but it is still mostly hand-curated grouping. It works for five hosts. It gets ugly at 200 hosts unless something is generating or enforcing those groups.

The enterprise pattern is usually not “make a playbook for every special server.”

It is closer to Terraform’s model:

inventory/source of truth declares desired state
roles/modules know how to converge that state
playbooks orchestrate broad phases
selectors limit scope by labels, tags, hostvars, or source-of-truth queries

So your instinct is correct: you do not want a playbook called something like:

deploy-main-worker-gpu-server.yml

except maybe as a temporary bootstrap wrapper.

You want something more like:

playbooks/
  site.yml
  bootstrap_windows_hosts.yml
  provision_hyperv_guests.yml
  configure_linux_runtimes.yml
  deploy_container_workloads.yml
  deploy_k3s.yml
  deploy_observability.yml
  deploy_ai_runtime.yml

Then the “main worker GPU server” is not encoded in the playbook name. It is encoded in inventory intent.

Your old contract was already drifting this way. It had service placement like ollama, litellm_gateway, openwebui, postgres, clickhouse, redis, and minio, with properties like GPU need, persistence, rebuild safety, and classification. That is the right idea. The issue is that the old scaffold used placeholders like main_node and network_node, and even the file says those role names are deprecated and need a more scalable schema.

The better pattern is “service/workload declarations,” not “host groups that you manually babysit.”

Example:

# inventory/host_vars/server-225-dkr-vm-01.yml
node_profile:
  site: home_primary
  asset: server-225
  runtime_planes:
    - docker_engine
    - ai_worker
  hardware_classes:
    - nvidia_gpu
    - high_vram
  policy_classes:
    - experimental
    - non_authoritative_data

workloads:
  ollama:
    enabled: true
  litellm:
    enabled: true
  openwebui:
    enabled: true
# inventory/host_vars/nsrv-dkr-vm-01.yml
node_profile:
  site: home_primary
  asset: network-server
  runtime_planes:
    - docker_engine
    - observability
    - storage_services
  hardware_classes:
    - bulk_storage
  policy_classes:
    - authoritative_data
    - lan_exposed_services

workloads:
  langfuse:
    enabled: true
  postgres:
    enabled: true
  clickhouse:
    enabled: true
  redis:
    enabled: true
  minio:
    enabled: true
  netbox:
    enabled: true

Then your Docker role does not need to care whether it is the main GPU worker or the network server. It only cares:

- name: Configure Docker Engine where requested
  hosts: all
  gather_facts: true
  tasks:
    - name: Skip hosts without docker_engine runtime plane
      ansible.builtin.meta: end_host
      when: "'docker_engine' not in (node_profile.runtime_planes | default([]))"

    - name: Install/configure Docker Engine
      ansible.builtin.include_role:
        name: docker_engine

That is the generic runtime-engine pattern you were reaching for.

Then workload deployment becomes data-driven:

- name: Deploy container workloads
  hosts: all
  gather_facts: true
  tasks:
    - name: Skip hosts that are not Docker workload targets
      ansible.builtin.meta: end_host
      when: "'docker_engine' not in (node_profile.runtime_planes | default([]))"

    - name: Deploy enabled workloads
      ansible.builtin.include_role:
        name: container_workload
      loop: "{{ workloads | dict2items }}"
      when: item.value.enabled | default(false) | bool
      vars:
        workload_name: "{{ item.key }}"
        workload_config: "{{ item.value }}"

That is much closer to Terraform:

host_vars = desired state
roles = modules/resources
playbooks = apply phases
facts/asserts = validation

Now, where NetBox fits:

NetBox should eventually own the durable facts:

device / VM
site
cluster
role
platform
IP address
parent host
tags
custom fields

But Ansible can still own the runtime desired state, especially while you’re iterating.

A strong model would be:

NetBox:
  server-225 exists
  server-225 has VM server-225-dkr-vm-01
  server-225 has VM server-225-k3s-vm-01
  server-225 has GPU tag
  network-server has storage tag
  IPs, interfaces, sites, clusters

Ansible inventory vars:
  docker_engine enabled here
  k3s enabled here
  workloads enabled here
  persistence policy
  firewall exposure
  deployment phase

Playbooks:
  install docker where runtime_planes contains docker_engine
  install k3s where runtime_planes contains k3s
  deploy workloads where workloads.<name>.enabled is true

So no, you should not make one playbook specifically for the big GPU worker server.

You make generic playbooks that apply to any node matching the contract:

# AI worker runtime
when:
  - "'ai_worker' in node_profile.runtime_planes"
  - "'nvidia_gpu' in node_profile.hardware_classes"
# authoritative storage runtime
when:
  - "'storage_services' in node_profile.runtime_planes"
  - "'authoritative_data' in node_profile.policy_classes"
# Kubernetes runtime
when:
  - "'k3s' in node_profile.runtime_planes"

That lets the main worker server be special without creating special-case playbooks.

For example:

# server-225-dkr-vm-01
node_profile:
  runtime_planes:
    - docker_engine
    - ai_worker
  hardware_classes:
    - nvidia_gpu
    - high_vram

workloads:
  ollama:
    enabled: true
    gpu_required: true
  litellm:
    enabled: true
  openwebui:
    enabled: true

The playbook remains generic:

- name: Deploy AI runtime workloads
  hosts: all
  tasks:
    - name: Require AI worker plane
      ansible.builtin.meta: end_host
      when: "'ai_worker' not in (node_profile.runtime_planes | default([]))"

    - name: Assert NVIDIA GPU class for GPU workloads
      ansible.builtin.assert:
        that:
          - "'nvidia_gpu' in (node_profile.hardware_classes | default([]))"
        fail_msg: "{{ inventory_hostname }} is marked ai_worker but lacks nvidia_gpu class."

    - name: Deploy AI workload stack
      ansible.builtin.include_role:
        name: ai_runtime_stack

For 200 servers, you would not manually maintain huge blocks like:

runtime_docker_engine:
  hosts:
    host1:
    host2:
    host3:

You would use one of these patterns:

1. Dynamic inventory from NetBox
2. Constructed inventory groups from host vars/tags
3. A generated inventory file committed to the repo
4. A small static inventory plus data-driven host_vars

For your homelab, I would not jump straight to full dynamic inventory complexity yet. I’d use a hybrid:

Phase 1:
  static host list
  rich host_vars
  generic playbooks
  assert gates

Phase 2:
  NetBox records devices/VMs/IPs/sites/tags
  Ansible pulls inventory from NetBox
  constructed groups created from NetBox tags/custom fields

Phase 3:
  service placement becomes a structured desired-state file
  playbooks deploy by workload declarations, not hostnames

A better replacement for the group you called out is not:

runtime_docker_engine:
  hosts:
    server-225-ubuntu:
    nsrv-dkr-01:

It is:

# host_vars/server-225-dkr-vm-01.yml
runtime_planes:
  docker_engine:
    enabled: true
    purpose: ai_worker
# host_vars/nsrv-dkr-vm-01.yml
runtime_planes:
  docker_engine:
    enabled: true
    purpose: storage_observability

Then playbooks select by hostvars:

- name: Build Docker Engine candidate list
  hosts: all
  gather_facts: false
  tasks:
    - name: Add Docker Engine hosts to runtime group
      ansible.builtin.group_by:
        key: runtime_docker_engine
      when: runtime_planes.docker_engine.enabled | default(false) | bool

Then later plays target the generated group:

- name: Configure Docker Engine
  hosts: runtime_docker_engine
  roles:
    - docker_engine

That is the missing technique: group_by.

You can also use constructed inventory later, but group_by is a simple bridge that keeps your source data in host_vars instead of static group membership.

The pattern looks like this:

- name: Classify hosts from declared intent
  hosts: all
  gather_facts: false
  tasks:
    - name: Group Docker Engine hosts
      ansible.builtin.group_by:
        key: runtime_docker_engine
      when: runtime_planes.docker_engine.enabled | default(false) | bool

    - name: Group K3s hosts
      ansible.builtin.group_by:
        key: runtime_k3s
      when: runtime_planes.k3s.enabled | default(false) | bool

    - name: Group AI workers
      ansible.builtin.group_by:
        key: workload_ai_worker
      when: workload_classes.ai_worker | default(false) | bool

    - name: Group authoritative storage hosts
      ansible.builtin.group_by:
        key: policy_authoritative_data
      when: policy.authoritative_data | default(false) | bool

Then:

- name: Configure Docker runtime
  hosts: runtime_docker_engine
  roles:
    - docker_engine

- name: Configure K3s runtime
  hosts: runtime_k3s
  roles:
    - k3s_node

- name: Deploy AI worker workloads
  hosts: workload_ai_worker:&runtime_docker_engine
  roles:
    - ai_worker_stack

That gives you the scale pattern you were looking for without pretending your homelab needs a full enterprise CMDB on day one.

For your current architecture, I’d name the conceptual server classes like this:

node_classes:
  control_executor:
    description: Mac control node; runs Ansible only; no service authority.

  gpu_worker:
    description: High-VRAM experimental/AI execution node.

  storage_observability:
    description: Authoritative persistent service node.

  k3s_runtime:
    description: Kubernetes runtime node or cluster member.

  docker_runtime:
    description: Plain Docker Engine runtime node.

  hyperv_host:
    description: Windows host that owns VMs, disks, drivers, firewall.

Then a node can have multiple classes:

node_classes:
  - gpu_worker
  - docker_runtime

or:

node_classes:
  - storage_observability
  - docker_runtime
  - k3s_runtime

This is the correction:

Do not make runtime_docker_engine the source of truth.

Make it a derived group.

Source of truth:

runtime_planes:
  docker_engine:
    enabled: true

Derived targeting group:

runtime_docker_engine

That is exactly the Terraform-like move you were trying to articulate. Data declares intent. Automation derives the execution graph.
