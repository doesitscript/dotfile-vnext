"""K3s-02 storage architecture — applied 2026-09-11 state.

Identity rule: guest mounts use LABEL= (never durable /dev/sdX).
Host SSDs are serial-bound NTFS volumes; guest disks are separate VHDXs.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.k8s.compute import Pod
from diagrams.onprem.compute import Server
from diagrams.onprem.monitoring import Grafana


with Diagram(
    "K3s-02 storage architecture",
    filename="storage-architecture",
    direction="LR",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"ranksep": "1.1", "nodesep": "0.7"},
):
    with Cluster("HOM-LAB-HVH-02 | Windows Hyper-V"):
        logs_ssd = Server("Samsung\nLOGS-HOST\nserial-bound NTFS")
        cache_ssd = Server("Plextor\nHOT-DATA-HOST\nserial-bound NTFS")
        cold_ssd = Server("Plextor\nCOLD-DATA-HOST\ncold-artifacts backing")
        cache_vhdx = Server("300 GiB dynamic VHDX\ncache | SCSI 0:2")
        cold_vhdx = Server("200 GiB dynamic VHDX\ncold artifacts | SCSI 0:4")
        logs_vhdx = Server("32 GiB dynamic VHDX\nlogs | SCSI 0:3")
        cache_ssd >> Edge(label="no RAID0; separate volumes") >> cache_vhdx
        cold_ssd >> Edge(label="no RAID0; separate volumes") >> cold_vhdx
        logs_ssd >> Edge(label="no RAID0; separate volumes") >> logs_vhdx

    with Cluster("hom-lab-ctl-k3s-02 | Ubuntu K3s guest"):
        root = Server("OS root\n~77 GiB\ncontrol plane only")
        cache = Server("LABEL=k3s-cache\n/mnt/k3s-cache")
        cold = Server("LABEL=k3s-cold\n/mnt/k3s-cold")
        logs = Server("LABEL=k3s-logs\n/mnt/k3s-logs")
        containerd = Server("containerd bind\ncache/containerd")
        local_path = Server("local-path PVCs\ncache/local-path")
        hf = Server("HF / vLLM cache\ncache/hf/hub")
        cold_models = Server("Inactive model archives\ncold/models/huggingface")
        pod_logs = Server("native podLogsDir\nlogs/pods")
        k3s = Server("K3s node\nReady\nDiskPressure=False")
        alloy = Grafana("Alloy\nstorage metrics")
        vllm = Pod("vLLM\nHF hostPath")

    cache_vhdx >> Edge(label="attach; mount by LABEL") >> cache
    cold_vhdx >> Edge(label="attach; mount by LABEL") >> cold
    logs_vhdx >> Edge(label="attach; mount by LABEL") >> logs
    cache >> containerd
    cache >> local_path
    cache >> hf
    cold >> cold_models
    logs >> pod_logs
    root >> k3s
    containerd >> k3s
    local_path >> k3s
    pod_logs >> k3s
    hf >> vllm
    k3s >> vllm
    k3s >> alloy
