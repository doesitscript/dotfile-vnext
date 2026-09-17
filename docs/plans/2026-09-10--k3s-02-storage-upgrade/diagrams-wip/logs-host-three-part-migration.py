"""LOGS-HOST three-part migration — desired end state vs complication.

Codex framing (2026-09-16): inclusive volume label becomes LOGS-HOST (F:).
K3s and Windows Event Logs can land on F: by VHDX relocate / redirect, but
Docker lives in a separate Linux VM and needs its own F:-backed attached disk
rather than writing directly to the Windows filesystem.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker
from diagrams.onprem.logging import Loki
from diagrams.k8s.controlplane import Kubelet


with Diagram(
    "LOGS-HOST three-part migration (desired end state)",
    filename="logs-host-three-part-migration",
    direction="LR",
    show=False,
    outformat="png",
    graph_attr={"ranksep": "1.0", "nodesep": "0.65", "pad": "0.3"},
):
    with Cluster("HOM-LAB-HVH-02 | Windows Hyper-V host"):
        logs_host = Server("F: volume\nlabel LOGS-HOST\ninclusive logs sink")
        win_events = Loki("Windows Event Logs\nredirect to F:")
        k3s_vhdx = Server("K3s logs VHDX\nrelocate existing disk to F:")
        docker_vhdx = Server("Docker log/data VHDX\nnew attach; backed by F:")

        win_events >> Edge(label="1 redirect\n(native Windows)") >> logs_host
        logs_host >> Edge(label="2 relocate\n(host file move)") >> k3s_vhdx
        logs_host >> Edge(label="3 new VHDX\nbacked by F:") >> docker_vhdx

    with Cluster("hom-lab-ctl-k3s-02 | Ubuntu K3s guest"):
        k3s_logs = Kubelet("LABEL=k3s-logs\n/mnt/k3s-logs\npodLogsDir")
        k3s_vhdx >> Edge(label="Hyper-V attach\nmount by LABEL") >> k3s_logs

    with Cluster("Docker Linux VM | separate guest (root ~92% full)"):
        docker = Docker("dockerd\nneeds attached disk\nnot Windows FS path")
        docker_data = Server("guest log/data mount\n(F:-backed VHDX)")
        docker_vhdx >> Edge(label="Hyper-V attach\n(not NTFS share)") >> docker_data
        docker_data >> docker
