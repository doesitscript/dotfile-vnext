"""vLLM model weight download path on hom-lab-ctl-k3s-02.

Shows where Hugging Face weights land on real disk before they are read into
GPU VRAM, and which physical device ultimately backs that space.
"""

from diagrams import Diagram, Edge
from diagrams.generic.os import Windows
from diagrams.generic.storage import Storage
from diagrams.k8s.compute import Pod
from diagrams.k8s.storage import PVC, StorageClass, Volume
from diagrams.onprem.network import Internet
from diagrams.programming.flowchart import InternalStorage

graph_attr = {
    "pad": "0.6",
    "nodesep": "1.2",
    "ranksep": "0.9",
    "fontsize": "13",
    "labelloc": "t",
}

with Diagram(
    "vLLM weights: Hub to disk to GPU (hom-lab-ctl-k3s-02)",
    filename="cst-hom-lab-ctl-dia-vllmcache-flow-01",
    show=False,
    direction="TB",
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    hub = Internet("Hugging Face Hub\nQwen2.5-Coder-32B-AWQ")
    pod = Pod("vLLM pod\nvllm-primary")
    pvc = PVC("PVC vllm-primary-hf-cache\nrequests 120Gi")
    sc = StorageClass("StorageClass local-path\nK3s default")
    pvdir = Volume("PV is a plain directory\n/var/lib/rancher/k3s/storage")
    rootfs = Storage("Guest disk /dev/root ext4\n77G total, 13G free")
    vhdx = Windows("HOM-LAB-HVH-02\nFixed VHDX 80GB on D:")
    vram = InternalStorage("GPU VRAM\nRTX 5090")

    hub >> Edge(label="  1. pod pulls weights on start\n  19 GB for this model") >> pod
    pod >> Edge(label="  2. writes /root/.cache/huggingface") >> pvc
    pvc >> Edge(label="  3. bound to") >> sc
    sc >> Edge(label="  4. makes a folder, sets no size limit", color="firebrick") >> pvdir
    pvdir >> Edge(label="  5. consumes real blocks") >> rootfs
    rootfs >> Edge(label="  6. backed by") >> vhdx

    pvdir >> Edge(
        label="  7. read into VRAM at model load",
        style="dashed",
        color="darkgreen",
    ) >> vram
