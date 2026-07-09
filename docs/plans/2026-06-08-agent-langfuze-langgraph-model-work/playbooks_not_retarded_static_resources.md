for this and related paybooks/roles we need to fix them. AS A RULE, WE DON'T STATICALLY PUT HOSTNAME IN PLAYBOOKS UNLESS EXPLICETLY TOLD TO DO SO, WE INSTEAD ADOPT PATTERNS LIKE THE FOLLOWING
So this:

hosts: hom-lab-ctl-k3s-02

should become something like:

hosts: k3s_gpu_nodes

or better:

hosts: container_orchestrator_k3s:&gpu_partition_enabled
Better naming

Instead of “container orchestration,” I’d use:

workload_runtime: k3s

or:

orchestrator: k3s

For GPU:

gpu_runtime: nvidia
gpu_partitioning: true

For role targeting:

node_capabilities:
  - k3s
  - nvidia_gpu
  - gpu_workload_node

#Better inventory model

Example host vars:

host_kind: vm
parent_hypervisor: HOM-LAB-HVH-02

workload_runtime:
  type: k3s
  role: worker

gpu:
  vendor: nvidia
  partitioned: true
  passthrough_mode: gpu_p
  workloads_enabled: true

node_capabilities:
  - k3s_node
  - gpu_workload_node
  - nvidia_container_runtime

### FIX THE ABOVE  IN MY PROJECT AND ON THESE RESOURCES IMMEDIATELY
