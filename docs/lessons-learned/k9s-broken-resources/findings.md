# K3s Broken Resources Report — hom-lab-ctl-k3s-02

**Collected:** 2026-07-09 ~09:53 CDT  
**Cluster:** `hom-lab-ctl-k3s-02` (`https://192.168.137.11:6443`)  
**kubectl context:** `hom-lab-ctl-k3s-02`  
**Node:** single control-plane `hom-lab-ctl-k3s-02` (Ready)

> **Note:** `hom-lab-ctl-k3s-01` context (`192.168.138.11:6443`) is **unreachable** from the controller (`no route to host`). That cluster is not included in this report.

---

## Executive summary

| Severity | Count | Theme |
|----------|-------|-------|
| **Critical** | 4 workloads | AI inference stack not operational |
| **Infrastructure** | 1 node condition | `nvidia.com/gpu: 0` despite GPU labels |
| **Degraded services** | 4 ClusterIP/NodePort | No ready endpoints |
| **Housekeeping** | 9 debug pods | Leftover `node-debugger-*` in `default` |

**Root cause families (3, independent):**

1. **Data plane unreachable** — Langfuse + LiteLLM cannot reach external fuzlang services at `192.168.50.234`.
2. **GPU host layer broken** — `dxgkrnl` / `/dev/dxg` not operational; device plugin cannot start.
3. **Scheduling capacity** — vLLM cannot schedule (no GPU + tight CPU/memory on single node).

---

## Healthy baseline (for contrast)

| Namespace | Resource | Status |
|-----------|----------|--------|
| kube-system | coredns, traefik, metrics-server, local-path-provisioner | Running |
| kube-system | helm-install-traefik jobs | Completed |
| nvidia-device-plugin | nvidia-device-plugin-mps-control-daemon DS | 0 desired (expected — no MPS-capable GPU) |

---

## Broken workloads (production)

### 1. `langfuse/langfuse-web` — CrashLoopBackOff

| Field | Value |
|-------|-------|
| Pod | `langfuse-web-7bff687954-8h6gm` |
| Deployment | `langfuse-web` — **0/1 available** |
| Restarts | 89+ |
| Helm | `langfuse` chart `1.5.31` (deployed 2026-07-08) |

**Evidence (container log):**
```
Error: P1001
Can't reach database server at `192.168.50.234:5432`
Applying database migrations failed.
Exiting...
```

**Configured dependencies (pod env):**
- Postgres: `192.168.50.234:5432` / db `langfuse`
- Redis: `192.168.50.234:6379`
- ClickHouse HTTP: `192.168.50.234:8123`
- MinIO/S3: `http://192.168.50.234:9000`

**Service impact:** `langfuse-web` Service has **no endpoints**.

**Diagnosis:** External storage-lane fuzlang data plane is not reachable from the cluster. Inventory contract: `fuzlang_storage_windows_publish_host: 192.168.50.234` → hvh-01 portproxy → dkr-01 (`192.168.138.10`). Legacy GPU-lane Postgres on `192.168.137.10` is retired (`stacks_fuzlang_net_state: absent` on dkr-02).

**Network probe from cluster (2026-07-09):**
```
nc 192.168.50.234:5432  → Connection timed out
nc 192.168.50.234:6379  → Connection timed out
nc 192.168.50.234:8123  → Connection timed out
nc 192.168.50.234:9000  → Connection timed out
nc 192.168.137.10:5432  → Connection refused
```

---

### 2. `langfuse/langfuse-worker` — CrashLoopBackOff

| Field | Value |
|-------|-------|
| Pod | `langfuse-worker-5cd56d98fd-47v8m` |
| Deployment | `langfuse-worker` — **0/1 available** |
| Restarts | 109+ |

**Evidence (container log):**
```
PrismaClientInitializationError: Can't reach database server at `192.168.50.234:5432`
errorCode: 'P1001'
```

**Events:** Liveness probe failures on `:3030/api/health` when process is up but DB health check fails.

**Diagnosis:** Same root cause as langfuse-web — Postgres unreachable.

---

### 3. `litellm/litellm` — CrashLoopBackOff

| Field | Value |
|-------|-------|
| Pod | `litellm-685cbbc574-89jnb` |
| Deployment | `litellm` — **0/1 available** |
| Restarts | 76+ |
| Helm | `litellm-helm` `1.91.0` (revision 2, deployed 2026-07-08) |

**Evidence (previous container log):**
```
httpx.ConnectError: All connection attempts failed
ERROR: Application startup failed. Exiting.
```
(Stack trace through Prisma `_setup_prisma_client` → `health_check`)

**Pod env (describe):**
```
DATABASE_HOST: 192.168.50.234
DATABASE_URL:  postgresql://langfuse:Pass%40w0rd1@192.168.50.234:5432/litellm
```

**Service impact:**
- `litellm` ClusterIP — **no endpoints**
- `litellm-lan` NodePort `:30400` — **no endpoints**
- Ingress `litellm-gateway-ingress` (`litellm.hom.lab`) — **no ADDRESS**

**Diagnosis:** LiteLLM proxy fails startup DB health check against same unreachable Postgres host.

---

### 4. `nvidia-device-plugin/nvidia-device-plugin` — CrashLoopBackOff

| Field | Value |
|-------|-------|
| Pod | `nvidia-device-plugin-sxvzg` |
| DaemonSet | `nvidia-device-plugin` — **0/1 ready** |
| Runtime class | `nvidia` |
| Restarts | 85+ |
| Helm | `nvidia-device-plugin` `0.17.1` (revision 3, deployed 2026-07-09) |

**Evidence (pod describe, last terminated state):**
```
Reason:  StartError
Message: failed to create containerd task: ... OCI runtime create failed:
  failed to create the automatic CDI modifier: failed to generate CDI spec for mode "auto":
  failed to create discoverer for WSL driver: no driver store paths found
Exit Code: 128
```

**Node GPU state (hom-lab-ctl-k3s-02):**
```
nvidia.com/gpu: 0          (Capacity and Allocatable)
nvidia.com/gpu.present=true (label only)
nvidia-smi -L → GPU access blocked by the operating system
/dev/dxg*     → does not exist
dxgkrnl       → not loaded (modprobe: Operation not permitted)
/usr/lib/wsl  → present (GPU-P driver store artifact layout exists)
```

**Diagnosis:** Helm install succeeded; failure is on the **guest GPU-P host layer**. Device plugin cannot advertise GPUs until `dxgkrnl` is loaded, `/dev/dxg` exists, and `nvidia-smi` works. Conflicting apt `nvidia-driver-580-server-open` from `k3s_nvidia_runtime` may also be incompatible with GPU-P WSL driver-store model.

---

### 5. `vllm-runtime/vllm-primary` — Pending (never scheduled)

| Field | Value |
|-------|-------|
| Pod | `vllm-primary-86f487845c-2k2bw` |
| Deployment | `vllm-primary` — **0/1 available** |
| Age | ~5h49m |

**Scheduler event:**
```
0/1 nodes are available:
  1 Insufficient cpu
  1 Insufficient memory
  1 Insufficient nvidia.com/gpu
preemption: 0/1 nodes are available: 1 No preemption victims found
```

**Pod requests/limits:**
```
requests: cpu 2, memory 8Gi, nvidia.com/gpu 1
limits:   cpu 8, memory 32Gi, nvidia.com/gpu 1
```

**Node allocatable:** cpu `2`, memory `~7.6Gi`, `nvidia.com/gpu: 0`  
**Already allocated (crashing pods still reserve):** cpu requests `1800m` (90%), memory requests `3980Mi` (52%)

**PVC:** `vllm-primary-hf-cache` — **Pending** (`WaitForPodScheduled` — local-path waits for pod placement)

**Service impact:** `vllm-primary` ClusterIP — **no endpoints**

**Diagnosis:** Blocked by missing GPU advertisement **and** single-node resource headroom. Will not schedule until device plugin is healthy and/or resource requests are reduced.

---

## Degraded cluster objects (no ready backends)

| Namespace | Object | Type | Issue |
|-----------|--------|------|-------|
| langfuse | `langfuse-web` | Service (NodePort :30000) | Empty endpoints |
| litellm | `litellm` | ClusterIP :4000 | Empty endpoints |
| litellm | `litellm-lan` | NodePort :30400 | Empty endpoints |
| litellm | `litellm-gateway-ingress` | Ingress | No ADDRESS assigned |
| vllm-runtime | `vllm-primary` | ClusterIP :8000 | Empty endpoints |
| vllm-runtime | `vllm-primary-hf-cache` | PVC | Pending (pod unscheduled) |
| kube-system | `traefik` | LoadBalancer | EXTERNAL-IP `<pending>` (expected on k3s; NodePort :31461 used) |

---

## Housekeeping (non-production noise)

Nine `node-debugger-hom-lab-ctl-k3s-02-*` pods in `default` namespace from diagnostic `kubectl debug node/...` sessions. States: `Completed`, `Error`. Safe to delete; not part of the AI stack.

---

## Dependency graph (why fixes must be ordered)

```mermaid
graph TB
  subgraph data [Track A - Data plane]
    FZ["fuzlang @ 192.168.50.234<br/>Postgres Redis CH MinIO"]
    FZ --> LF_WEB["langfuse-web"]
    FZ --> LF_WRK["langfuse-worker"]
    FZ --> LLM["litellm"]
  end

  subgraph gpu [Track B - GPU foundation]
    GPUP["Hyper-V GPU-P + dxgkrnl"]
    GPUP --> NDVP["nvidia-device-plugin"]
    NDVP --> GPU_CAP["nvidia.com/gpu: 1"]
    GPU_CAP --> VLLM["vllm-primary"]
  end

  subgraph cap [Track C - Node capacity]
    GPU_CAP --> VLLM
    MEM["~7.6Gi allocatable"] --> VLLM
  end

  style FZ fill:#5a1a1a,color:#fff
  style GPUP fill:#5a1a1a,color:#fff
  style VLLM fill:#4a3f2e,color:#fff
```

---

## Recommended remediation order

| Order | Track | Action | Unblocks |
|-------|-------|--------|----------|
| 1 | Data plane | Deploy `stacks_fuzlang_net` on storage lane (`playbooks/deploy_network_stacks.yaml` → hvh-01/dkr-01) | langfuse-web, langfuse-worker, litellm |
| 1b | Data plane | Ensure k3s-02 guest can route to `192.168.50.234` (or override connect address to guest-reachable IP) | same |
| 2 | GPU host | Attach GPU partition on hvh-02; complete GPU-P guest runtime (`dxgkrnl`, `/dev/dxg`, `nvidia-smi`) | nvidia-device-plugin |
| 3 | GPU plugin | Re-run `k3s_nvidia_device_plugin` after host GPU works | `nvidia.com/gpu` capacity |
| 4 | vLLM | Reconcile memory/cpu requests for single-node lab; then redeploy `vllm-primary` | inference backend for LiteLLM `code-deep` lane |

---

## Inventory / playbook anchors

| Component | Repo surface |
|-----------|--------------|
| Fuzlang connect contract | `inventory/group_vars/all/fuzlang_external_services.yml` |
| Langfuse Helm | `roles/k3s_langfuse_platform`, `playbooks/deploy_langfuse_platform.yaml` |
| LiteLLM Helm | `roles/k3s_litellm_gateway`, `playbooks/deploy_litellm_gateway.yaml` |
| NVIDIA device plugin | `roles/k3s_nvidia_device_plugin`, `playbooks/deploy_gpu_infrastructure.yaml` |
| vLLM runtime | `roles/k3s_vllm_runtime`, `playbooks/deploy_vllm_runtime.yaml` |
| Full stack orchestration | `playbooks/deploy_ai_inference_stack.yaml` |
| Storage lane deploy | `playbooks/deploy_network_stacks.yaml` |
| GPU-P guest runtime | `roles/hyperv_ubuntu_gpu_p_linux_guest_runtime` |

---

## Evidence collection commands used

```bash
kubectl config use-context hom-lab-ctl-k3s-02
kubectl get pods -A -o wide
kubectl describe node hom-lab-ctl-k3s-02
kubectl logs -n <ns> <pod> --previous
kubectl run netprobe --rm -i --restart=Never --image=busybox:1.36 -- \
  sh -c 'nc -zv -w4 192.168.50.234 5432'
helm list -A
```

---

## Operator evidence knobs

- `-vvv` on Ansible playbook runs when hosts are reachable
- `kubectl describe pod -n <ns> <pod>` and `kubectl logs --previous`
- `kubectl get events -A --field-selector type!=Normal`
