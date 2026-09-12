from diagrams import Cluster, Diagram, Edge
from diagrams.k8s.compute import Pod
from diagrams.onprem.compute import Server


with Diagram(
    "K3s-02 storage architecture",
    filename="storage-architecture",
    direction="LR",
    show=False,
    outformat="png",
    graph_attr={"ranksep": "1.2", "nodesep": "0.8"},
):
    with Cluster("HOM-LAB-HVH-02 | Windows Hyper-V"):
        host_ssds = Server("Separate host SSDs\nK3S-LOGS-HOST\nK3S-CACHE-HOST\nK3S-COLD-HOST")
        cache_vhdx = Server("300 GiB dynamic VHDX\ncache")
        logs_vhdx = Server("32 GiB dynamic VHDX\nlogs/scratch")
        host_ssds >> Edge(label="separate volumes; no RAID0") >> Server("D: VHDX storage")

    with Cluster("hom-lab-ctl-k3s-02 | Ubuntu K3s guest"):
        root = Server("77 GiB root\nOS only")
        cache = Server("/mnt/k3s-cache\ncontainerd / local-path / HF")
        logs = Server("/mnt/k3s-logs/pods\nnative podLogsDir")
        k3s = Server("K3s node\nReady\nDiskPressure=False")
        vllm = Pod("vLLM\nHF hostPath")

    cache_vhdx >> Edge(label="attached SCSI 0:2") >> cache
    logs_vhdx >> Edge(label="attached SCSI 0:3") >> logs
    root >> k3s
    cache >> k3s
    logs >> k3s
    k3s >> vllm
