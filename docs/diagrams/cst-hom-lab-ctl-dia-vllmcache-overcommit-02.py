"""Why a 120Gi PVC does not mean 120Gi of space on hom-lab-ctl-k3s-02.

K3s local-path satisfies a PVC by creating a directory on the node root
filesystem. Nothing compares the requested size against free space, and
nothing stops a pod from writing past it, so two PVCs can claim 320Gi on a
77G disk and neither claim is ever checked.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.generic.storage import Storage
from diagrams.k8s.clusterconfig import Quota
from diagrams.k8s.compute import Pod
from diagrams.k8s.storage import PVC, StorageClass
from diagrams.programming.flowchart import StoredData

graph_attr = {
    "pad": "0.6",
    "nodesep": "0.9",
    "ranksep": "1.5",
    "fontsize": "13",
    "labelloc": "t",
}

with Diagram(
    "PVCs claim 320Gi on a 77G disk: local-path never checks",
    filename="cst-hom-lab-ctl-dia-vllmcache-overcommit-02",
    show=False,
    direction="TB",
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    with Cluster("What Kubernetes was asked for: 320Gi"):
        pvc_vllm = PVC("vllm-primary-hf-cache\nrequests 120Gi")
        pvc_comfy = PVC("comfyui-models\nrequests 200Gi")

    sc = StorageClass("StorageClass local-path\nmkdir only")
    no_quota = Quota("No ResourceQuota\nNo filesystem quota")
    disk = Storage("Real device /dev/root ext4\n77G total, 64G used, 13G free")

    with Cluster("What is really on that 77G disk today"):
        used_img = StoredData("containerd images\n33 G")
        used_hf = StoredData("HF model cache\n19 G")
        used_ans = StoredData("ansible state\n5 G")
        headroom = StoredData("free headroom\n13 G")

    with Cluster("Shared failure when it fills"):
        pod_vllm = Pod("vLLM pod")
        pod_comfy = Pod("ComfyUI pod")

    pvc_vllm >> Edge(label="  size is only a label") >> sc
    pvc_comfy >> Edge(label="  size is only a label") >> sc

    no_quota >> Edge(
        label="  nothing rejects an oversized write",
        style="dashed",
        color="firebrick",
        constraint="false",
    ) >> sc

    sc >> Edge(
        label="  both folders land on one filesystem",
        color="firebrick",
        penwidth="2",
    ) >> disk

    disk >> Edge(style="dotted", color="gray40") >> used_img
    disk >> Edge(style="dotted", color="gray40") >> used_hf
    disk >> Edge(style="dotted", color="gray40") >> used_ans
    disk >> Edge(style="dotted", color="gray40") >> headroom

    headroom >> Edge(label="  ENOSPC hits both", color="firebrick") >> pod_vllm
    headroom >> Edge(color="firebrick") >> pod_comfy
