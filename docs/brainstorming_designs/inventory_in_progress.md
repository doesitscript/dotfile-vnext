Yes. I’d model your two servers like this.

## Core idea

```yaml
hom-lab-ctl-hvh-01:
  role: flagship AI compute / GPU workhorse

hom-lab-ctl-hvh-02:
  role: storage-heavy secondary AI compute / support runtime
```

## Recommended inventory structure

```yaml
# inventory/host_vars/hom-lab-ctl-hvh-01.yaml

host_kind: hyperv_host
platform_os: windows
infrastructure_role: ai_compute_host

compute:
  class: flagship
  scheduling_weight: 100

gpu:
  vendor: nvidia
  ai_tier: tier1
  role: ai_compute_primary
  compute_class: primary_ai_accelerator
  runtime_eligible: true
  partition_source: true
  workload_classes:
    - local_llm_inference
    - ai_agent_runtime
    - primary_model_runtime
    - gpu_partition_source

ai_runtime:
  host_local:
    enabled: true
    engine: ollama
    exposure: localhost
    purpose: local_model_serving
    runtime_role: primary_runtime

  routing:
    preferred_for:
      - large_local_models
      - primary_coding_models
      - high_context_reasoning
      - latency_sensitive_inference
    avoid_for:
      - bulk_storage
      - minio_primary
```

```yaml
# inventory/host_vars/hom-lab-ctl-hvh-02.yaml

host_kind: hyperv_host
platform_os: windows
infrastructure_role: storage_ai_compute_host

compute:
  class: performance
  scheduling_weight: 70

gpu:
  vendor: nvidia
  ai_tier: tier2
  role: ai_compute_secondary
  compute_class: secondary_ai_accelerator
  runtime_eligible: true
  partition_source: true
  workload_classes:
    - local_llm_inference
    - ai_agent_runtime
    - secondary_model_runtime
    - embeddings
    - batch_inference
    - gpu_partition_source

storage:
  class: high_capacity
  role: primary_storage_host
  workload_classes:
    - minio
    - model_cache
    - huggingface_cache
    - langfuse_storage
    - artifact_storage

memory:
  class: high_memory
  preferred_for:
    - model_cache
    - vector_indexes
    - observability_backends
    - batch_jobs

ai_runtime:
  host_local:
    enabled: true
    engine: ollama
    exposure: localhost
    purpose: secondary_local_model_serving
    runtime_role: secondary_runtime

  routing:
    preferred_for:
      - medium_local_models
      - embeddings
      - batch_inference
      - reviewer_agents
      - tester_agents
      - storage_adjacent_ai_jobs
    avoid_for:
      - largest_models
      - latency_critical_primary_runtime
```

## Group inventory

```ini
# inventory/groups.ini

[hyperv_hosts]
hom-lab-ctl-hvh-01
hom-lab-ctl-hvh-02

[windows_hosts]
hom-lab-ctl-hvh-01
hom-lab-ctl-hvh-02

[windows_ai_runtime_hosts]
hom-lab-ctl-hvh-01
hom-lab-ctl-hvh-02

[ai_host_local_runtime]
hom-lab-ctl-hvh-01
hom-lab-ctl-hvh-02

[ai_tier1_gpu_hosts]
hom-lab-ctl-hvh-01

[ai_tier2_gpu_hosts]
hom-lab-ctl-hvh-02

[gpu_partition_source_hosts]
hom-lab-ctl-hvh-01
hom-lab-ctl-hvh-02

[storage_heavy_hosts]
hom-lab-ctl-hvh-02

[primary_ai_compute_hosts]
hom-lab-ctl-hvh-01

[secondary_ai_compute_hosts]
hom-lab-ctl-hvh-02
```

## Better playbook

```yaml
- name: Converge host-local model runtime
  hosts: ai_host_local_runtime
  gather_facts: false

  roles:
    - role: windows_ollama_runtime
      when:
        - ai_runtime.host_local.enabled | bool
        - ai_runtime.host_local.engine == "ollama"
        - gpu.runtime_eligible | bool
      tags:
        - ai_runtime
        - ollama
        - windows
```

## Better GPU-P playbook targeting

```yaml
- name: Converge Hyper-V GPU partition source hosts
  hosts: gpu_partition_source_hosts
  gather_facts: false

  roles:
    - role: hyperv_gpu_p_host_precheck
      tags:
        - gpu_p
        - precheck

    - role: hyperv_gpu_partition_adapter
      when:
        - gpu.partition_source | bool
        - gpu.runtime_eligible | bool
      tags:
        - gpu_p
        - hyperv
```

## Recommended tier definitions

```yaml
gpu_tiers:
  tier1:
    label: primary_ai_compute
    description: Highest-priority GPU host for large local models and primary inference.
    scheduling_weight: 100

  tier2:
    label: secondary_ai_compute
    description: Secondary GPU host for medium models, agents, embeddings, testing, and batch inference.
    scheduling_weight: 70

  tier3:
    label: development_or_laptop_gpu
    description: Lightweight GPU node for dev/test only.
    scheduling_weight: 30

  tier4:
    label: cpu_only
    description: CPU fallback only.
    scheduling_weight: 0
```

## NetBox custom fields I’d add

```yaml
custom_fields:
  compute_class:
    values:
      - flagship
      - performance
      - standard
      - lightweight
      - cpu_only

  gpu_ai_tier:
    values:
      - tier1
      - tier2
      - tier3
      - tier4

  gpu_runtime_eligible:
    type: boolean

  gpu_partition_source:
    type: boolean

  ai_runtime_enabled:
    type: boolean

  ai_runtime_engine:
    values:
      - ollama
      - vllm
      - litellm
      - none

  ai_scheduling_weight:
    type: integer

  storage_class:
    values:
      - high_capacity
      - standard
      - none
```

## My final recommendation

Use these as your stable labels:

```yaml
hom-lab-ctl-hvh-01:
  gpu.ai_tier: tier1
  gpu.role: ai_compute_primary
  gpu.compute_class: primary_ai_accelerator
  compute.class: flagship
  compute.scheduling_weight: 100

hom-lab-ctl-hvh-02:
  gpu.ai_tier: tier2
  gpu.role: ai_compute_secondary
  gpu.compute_class: secondary_ai_accelerator
  compute.class: performance
  compute.scheduling_weight: 70
  storage.class: high_capacity
  memory.class: high_memory
```

That gives Ansible enough structure to make decisions without hardcoding hostnames.
