"""Lab ComfyUI architecture — Phase B on k3s-02 RTX 5090 time-share."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.k8s.compute import Deploy
from diagrams.k8s.network import Ing, SVC
from diagrams.k8s.storage import PVC
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "Lab ComfyUI — k3s-02 Phase B",
    filename="comfyui-lab-architecture",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")
    browser = Client("Browser\ncomfyui.hom.lab:30188")

    with Cluster("HVH-02 Hyper-V"):
        with Cluster("hom-lab-ctl-k3s-02 · RTX 5090"):
            publish = Ing("LAN publish\n:30188")
            svc = SVC("Service\ncomfyui")
            deploy = Deploy("Deployment\nk3s_comfyui_runtime")
            pvc = PVC("PVC\ncomfyui-models")
            # Mutual exclusion note via edge to paused Ornith
            ornith = Docker("Ornith vLLM\n(absent while Comfy)")

    ansible = Server("Ansible\ndeploy_comfyui_runtime")

    operator >> browser >> publish >> svc >> deploy
    deploy >> pvc
    deploy >> Edge(label="GPU exclusive", style="dashed") >> ornith
    ansible >> Edge(label="present|absent") >> deploy
