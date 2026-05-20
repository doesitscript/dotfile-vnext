# Research: vLLM Runtime and Hugging Face Cache

**Date:** 2026-05-19  
**Target Platform:** K3s Kubernetes cluster with RTX 5090 GPU  
**Initial Model:** Qwen/Qwen3-0.6B (testing)

## Executive Summary

This research document compiles findings for deploying vLLM runtime with GPU support and Hugging Face model caching on K3s. Key findings:

- **vLLM deployment** is well-documented with official Docker images and Helm charts
- **NVIDIA GPU Operator** is the standard path for GPU support on K3s
- **Model caching strategies** vary from simple per-pod downloads to sophisticated shared storage
- **Small models** like Qwen3-0.6B require 2-3GB VRAM (FP16) making them ideal for initial testing
- **Ansible automation** should focus on NVIDIA driver prerequisites and node configuration

---

## 1. vLLM Official Documentation and Deployment

### Official Resources

- **Main docs:** https://docs.vllm.ai/
- **Docker deployment:** https://docs.vllm.ai/en/v0.20.1/deployment/docker/
- **Helm charts:** https://docs.vllm.ai/en/latest/examples/deployment/chart-helm/
- **Production stack:** https://github.com/vllm-project/production-stack

### Docker Image: vllm/vllm-openai

The official `vllm/vllm-openai` image is production-ready and supports:

- **OpenAI-compatible API** on port 8000 (default)
- **GPU passthrough** via `--runtime nvidia --gpus all`
- **Hugging Face cache mounting** at `/root/.cache/huggingface`
- **Environment variables:**
  - `HF_TOKEN` for Hugging Face authentication
  - `HF_HOME` for cache directory (default: `~/.cache/huggingface`)
  - `VLLM_CACHE_ROOT` for vLLM-specific cache

### Example Docker Command

```bash
docker run --runtime nvidia --gpus all \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  --env "HF_TOKEN=$HF_TOKEN" \
  -p 8000:8000 \
  --ipc=host \
  vllm/vllm-openai:latest \
  --model Qwen/Qwen3-0.6B
```

**Key Docker flags:**
- `--ipc=host` or `--shm-size` required for PyTorch shared memory (tensor parallel inference)
- `--runtime nvidia` enables GPU access via NVIDIA Container Toolkit

### Kubernetes Deployment

vLLM provides an official Helm chart in the production-stack repository:

```bash
helm repo add vllm https://vllm-project.github.io/production-stack
helm install vllm vllm/vllm-stack -f values.yaml
```

**Key Helm chart features:**
- GPU resource requests/limits (`nvidia.com/gpu`)
- Persistent volume claims for model cache
- Init containers for model pre-download
- Horizontal pod autoscaling support
- ConfigMaps and Secrets for environment configuration

---

## 2. NVIDIA GPU Operator for K3s

### Official Documentation

- **GPU Operator docs:** https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/25.10/getting-started.html
- **K3s-specific guide:** https://docs.vultr.com/how-to-install-k3s-with-nvidia-gpu-operator-on-ubuntu-22-04

### Installation Steps

**Current version:** v25.10.1 (stable)

```bash
# 1. Add NVIDIA Helm repository
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

# 2. Install GPU Operator (K3s-specific)
helm install --wait gpu-operator \
  -n gpu-operator --create-namespace \
  nvidia/gpu-operator \
  --version=v25.10.1 \
  --set driver.enabled=false
```

**K3s considerations:**
- K3s uses `containerd` by default (compatible with GPU Operator)
- Set `driver.enabled=false` if NVIDIA drivers are pre-installed on the host
- NVIDIA Container Toolkit is deployed automatically by the Operator

### Prerequisites

- Kubernetes v1.19+ (K3s qualifies)
- `kubectl` and `helm` CLIs
- All GPU worker nodes must run the same OS version (or pre-install drivers)
- Node Feature Discovery (NFD) is deployed automatically by default

### Verification

After installation, verify GPU availability:

```bash
# Check for nvidia.com/gpu resource
kubectl get nodes -o json | jq '.items[].status.capacity'

# Test with CUDA sample pod
kubectl apply -f cuda-vectoradd.yaml
kubectl logs pod/cuda-vectoradd
```

---

## 3. vLLM Kubernetes Deployment Examples

### Production Stack Helm Chart

**Repository:** https://github.com/vllm-project/production-stack

The production stack Helm chart provides:

- **Multi-model support:** Deploy multiple serving engines with different models
- **PersistentVolume integration:** Load models from existing PVs
- **GPU resource management:** Configure requests and limits
- **Init containers:** Pre-download models before main container starts

### Minimal Deployment Example

```yaml
# values.yaml
image:
  repository: "vllm/vllm-openai"
  tag: "latest"
  command: ["vllm", "serve", "/data/", "--served-model-name", "qwen3-0.6b", "--host", "0.0.0.0", "--port", "8000"]

resources:
  requests:
    cpu: 4
    memory: 16Gi
    nvidia.com/gpu: 1
  limits:
    cpu: 4
    memory: 16Gi
    nvidia.com/gpu: 1

extraInit:
  pvcStorage: "50Gi"
  modelDownload:
    enabled: true
    image:
      repository: "huggingface/transformers-pytorch-gpu"
      tag: "latest"
```

### GPU Resource Limits

**Kubernetes GPU scheduling rules:**
- GPU limits can be specified without requests (Kubernetes uses limit as request)
- GPU can be specified in both limits and requests, but values must be equal
- GPU requests cannot be specified without limits

**Example pod specification:**
```yaml
resources:
  limits:
    nvidia.com/gpu: 1
```

---

## 4. Hugging Face Model Cache Configuration

### Environment Variables

**Primary cache control:**
- `HF_HOME`: Root directory for all Hugging Face data (default: `~/.cache/huggingface`)
- `HF_TOKEN`: User access token for authentication
- `HF_HUB_CACHE`: Specific cache for models/datasets (default: `$HF_HOME/hub`)

**vLLM-specific:**
- `VLLM_CACHE_ROOT`: Root directory for vLLM cache files
- `VLLM_CONFIG_ROOT`: Root directory for vLLM configuration files

### Kubernetes PersistentVolume Patterns

**Shared cache (recommended for multi-pod):**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: huggingface-cache
spec:
  accessModes:
    - ReadWriteMany  # NFS, CephFS, or cloud provider RWX storage
  resources:
    requests:
      storage: 50Gi
```

**Key considerations:**
- **ReadWriteMany (RWX)** access mode required for multiple pods
- **Storage size:** Small models (Qwen3-0.6B) need ~3GB; larger models (70B) need 140GB+
- **Storage backend:** NFS, CephFS, EFS (AWS), or cloud provider RWX storage

### Model Download Strategies

**1. vLLM Native Download (simplest):**
- Each pod downloads model on first startup
- Model cached in PV for subsequent startups
- Risk of race conditions if multiple pods start simultaneously

**2. Init Container Download (recommended):**
```yaml
initContainers:
  - name: download-model
    image: huggingface/transformers-pytorch-gpu:latest
    command: ["python", "-c"]
    args:
      - |
        from transformers import AutoModel
        AutoModel.from_pretrained("Qwen/Qwen3-0.6B", cache_dir="/cache")
    volumeMounts:
      - name: model-cache
        mountPath: /cache
```

**3. Job-Based Pre-Population (production):**
- Dedicated Kubernetes Job downloads model before inference pods start
- Avoids race conditions
- Explicit control over when models are populated

**4. KServe LocalModelCache (advanced):**
- CRD for managing model caching on nodes
- Automatically handles node affinity and download jobs
- Best for per-node caching with local SSDs

### DigitalOcean's Recommendations (from research)

From the DigitalOcean vLLM Kubernetes guide:

- **Control your model sources:** Mirror models to storage you control (avoid external dependencies)
- **Shared storage for multi-replica:** Use NFS or ReadWriteMany PVC with central pre-population
- **Per-node jobs for performance:** Download to node-local SSDs for fastest warm starts
- **Test under realistic conditions:** Performance varies by provider and configuration

---

## 5. GPU Resource Management in K3s

### nvidia.com/gpu Resource

After GPU Operator installation, nodes advertise `nvidia.com/gpu` in their capacity:

```bash
kubectl describe node <node-name> | grep nvidia.com/gpu
```

### Resource Quotas and Limits

**Namespace-level GPU quota:**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: gpu-quota
  namespace: vllm-runtime
spec:
  hard:
    requests.nvidia.com/gpu: "2"
    limits.nvidia.com/gpu: "2"
```

**LimitRange for defaults:**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: gpu-limit-range
  namespace: vllm-runtime
spec:
  limits:
    - type: Container
      default:
        nvidia.com/gpu: "1"
      defaultRequest:
        nvidia.com/gpu: "1"
```

### Node Affinity for GPU Nodes

Ensure vLLM pods only schedule on GPU nodes:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: nvidia.com/gpu.product
              operator: In
              values:
                - NVIDIA-GeForce-RTX-5090
```

---

## 6. Model Selection: Qwen3-0.6B

### VRAM Requirements

| Quantization | VRAM | Context Length | Use Case |
|--------------|------|----------------|----------|
| Q4_K_M       | 1.9-2 GB | 4K  | Basic inference |
| Q5_K_M       | 2 GB     | 8K+ | Good quality |
| Q8           | 3 GB     | 16K+ | Near-lossless |
| FP16/BF16    | 3-3.2 GB | Max | Full precision |

**Runtime overhead:** Add ~1.5GB for KV cache and context handling

**Recommended hardware:**
- **Minimum:** 12GB VRAM GPU (RTX 3060, Intel Arc B580)
- **Comfortable:** 16GB VRAM (RTX 4060 Ti, Apple M4 with unified memory)
- **Target (RTX 5090):** 24GB VRAM — plenty of headroom for full precision + large context

### Docker Example for Qwen3-0.6B

```bash
docker run --runtime nvidia --gpus all \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  --env "HF_TOKEN=$HF_TOKEN" \
  -p 8000:8000 \
  --ipc=host \
  vllm/vllm-openai:latest \
  --model Qwen/Qwen3-0.6B \
  --dtype bfloat16
```

---

## 7. Ansible Automation for GPU Prerequisites

### Ansible Roles to Create

**1. `nvidia_gpu_driver` (Ubuntu/K3s nodes):**
- Install NVIDIA drivers on host
- Configure containerd for GPU support
- Verify driver installation with `nvidia-smi`

**2. `k3s_gpu_node_config`:**
- Label nodes with `nvidia.com/gpu=present`
- Configure K3s for GPU workloads
- Set up containerd runtime configuration

**3. `nvidia_gpu_operator`:**
- Install NVIDIA GPU Operator via Helm
- Configure operator for K3s-specific settings
- Verify GPU Operator deployment

**4. `vllm_runtime`:**
- Create namespace for vLLM deployments
- Set up PersistentVolumeClaim for model cache
- Deploy vLLM via Helm chart
- Configure HF_TOKEN secret

### Ansible Task Examples

**Install NVIDIA drivers (Ubuntu):**
```yaml
- name: Install NVIDIA driver
  ansible.builtin.apt:
    name:
      - nvidia-driver-535
      - nvidia-utils-535
    state: present
    update_cache: yes
  when: ansible_facts['os_family'] == 'Debian'

- name: Verify NVIDIA driver
  ansible.builtin.command: nvidia-smi
  register: nvidia_smi_output
  changed_when: false
  failed_when: nvidia_smi_output.rc != 0
```

**Install GPU Operator:**
```yaml
- name: Add NVIDIA Helm repository
  kubernetes.core.helm_repository:
    name: nvidia
    repo_url: https://helm.ngc.nvidia.com/nvidia

- name: Install NVIDIA GPU Operator
  kubernetes.core.helm:
    name: gpu-operator
    chart_ref: nvidia/gpu-operator
    release_namespace: gpu-operator
    create_namespace: true
    chart_version: v25.10.1
    values:
      driver:
        enabled: false  # Drivers pre-installed on host
```

**Deploy vLLM:**
```yaml
- name: Create vLLM namespace
  kubernetes.core.k8s:
    name: vllm-runtime
    api_version: v1
    kind: Namespace
    state: present

- name: Create Hugging Face token secret
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: Secret
      metadata:
        name: huggingface-token
        namespace: vllm-runtime
      type: Opaque
      data:
        HF_TOKEN: "{{ vault_huggingface_token | b64encode }}"

- name: Deploy vLLM via Helm
  kubernetes.core.helm:
    name: vllm-qwen
    chart_ref: vllm/vllm-stack
    release_namespace: vllm-runtime
    values:
      image:
        repository: vllm/vllm-openai
        tag: latest
      resources:
        requests:
          nvidia.com/gpu: 1
        limits:
          nvidia.com/gpu: 1
      extraInit:
        pvcStorage: "50Gi"
```

---

## 8. Next Steps for Implementation

### Phase 1: GPU Infrastructure (Prerequisite)

1. **Install NVIDIA drivers** on RTX 5090 GPU node
2. **Deploy NVIDIA GPU Operator** on K3s cluster
3. **Verify GPU availability** with test pod

### Phase 2: vLLM Deployment

1. **Create PersistentVolumeClaim** for Hugging Face cache (50GB, RWX if multi-pod)
2. **Deploy vLLM** with Qwen3-0.6B model via Helm chart
3. **Test OpenAI-compatible API** on port 8000
4. **Verify model caching** (subsequent pod starts should be fast)

### Phase 3: Ansible Automation

1. **Create `nvidia_gpu_driver` role** for host driver installation
2. **Create `nvidia_gpu_operator` role** for K3s GPU Operator deployment
3. **Create `vllm_runtime` role** for vLLM deployment and configuration
4. **Test playbook** against K3s cluster with GPU node

---

## Sources Checked

1. **vLLM Official Documentation**
   - Docker deployment guide: https://docs.vllm.ai/en/v0.20.1/deployment/docker/
   - Helm charts: https://docs.vllm.ai/en/latest/examples/deployment/chart-helm/
   - Production stack: https://github.com/vllm-project/production-stack

2. **NVIDIA GPU Operator Documentation**
   - Installation guide: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/25.10/getting-started.html
   - K3s guide: https://docs.vultr.com/how-to-install-k3s-with-nvidia-gpu-operator-on-ubuntu-22-04

3. **Hugging Face Integration**
   - Environment variables: https://huggingface.co/docs/huggingface_hub/v0.26.3/en/package_reference/environment_variables
   - vLLM integration: https://docs.vllm.ai/en/latest/design/huggingface_integration.html

4. **Kubernetes GPU Scheduling**
   - GPU scheduling: https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/
   - K3s GPU workloads: https://oneuptime.com/blog/post/2026-03-20-k3s-gpu-workloads/view

5. **Model Caching Strategies**
   - DigitalOcean vLLM guide: https://www.digitalocean.com/community/tutorials/vllm-kubernetes-model-loading-caching-strategies

6. **Qwen3-0.6B Model**
   - Hardware requirements: https://llmhardware.io/models/Qwen--Qwen3-0.6B
   - Model card: https://huggingface.co/Qwen/Qwen3-0.6B-Base

---

## Appendix: Key Configuration Files

### values.yaml for vLLM Helm Chart

```yaml
image:
  repository: "vllm/vllm-openai"
  tag: "latest"
  command: ["vllm", "serve", "Qwen/Qwen3-0.6B", "--host", "0.0.0.0", "--port", "8000", "--dtype", "bfloat16"]

containerPort: 8000
servicePort: 8000

replicaCount: 1

resources:
  requests:
    cpu: 4
    memory: 16Gi
    nvidia.com/gpu: 1
  limits:
    cpu: 4
    memory: 16Gi
    nvidia.com/gpu: 1

gpuModels:
  - "NVIDIA-GeForce-RTX-5090"

extraInit:
  pvcStorage: "50Gi"
  modelDownload:
    enabled: false  # Models download on-demand via vLLM

secrets:
  HF_TOKEN: ""  # Set via environment or Ansible vault

configs:
  HF_HOME: "/cache/huggingface"
  VLLM_CACHE_ROOT: "/cache/vllm"

readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10

livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 60
  periodSeconds: 30
```

### PersistentVolumeClaim for Model Cache

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: huggingface-cache
  namespace: vllm-runtime
spec:
  accessModes:
    - ReadWriteOnce  # Single node for initial testing
    # - ReadWriteMany  # Use for multi-pod deployments
  resources:
    requests:
      storage: 50Gi
  storageClassName: local-path  # K3s default, adjust as needed
```

---

## End of Research Document
