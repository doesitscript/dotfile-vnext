"""ComfyUI place in the creative studio — generic roles, not content themes."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.k8s.compute import Deploy
from diagrams.k8s.network import Ing, SVC
from diagrams.k8s.storage import PVC
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.75"}

with Diagram(
    "ComfyUI studio setup — roles and surfaces",
    filename="comfyui-studio-setup",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("Chat and coaching"):
        webui = Docker("Chat UI\nOpen WebUI")
        litellm = Docker("Chat gateway\nLiteLLM")
        ollama = Server("Desktop chat runtime\nOllama coaching")

    with Cluster("Pixel engines"):
        a1111 = Server("Still bootstrap\nAutomatic1111")
        with Cluster("Phase B high-VRAM"):
            publish = Ing("LAN publish")
            svc = SVC("Service")
            comfy = Deploy("Node-graph runtime\nComfyUI")
            pvc = PVC("Model volume")
            ornith = Docker("Text LLM runtime\n(paused while Comfy)")

    with Cluster("Studio working set"):
        share = Server("Lab share\ninputs / outputs / presets")
        catalog = Server("Model catalog\nweights inventory")

    ansible = Server("Ansible lifecycle\npresent|absent")

    operator >> webui >> litellm >> ollama
    operator >> Edge(label="Images / direct UI") >> a1111
    operator >> Edge(label="graphs / API") >> publish >> svc >> comfy
    comfy >> pvc
    comfy >> Edge(label="GPU exclusive", style="dashed") >> ornith
    a1111 >> share
    comfy >> share
    catalog >> pvc
    catalog >> a1111
    ansible >> Edge(label="Comfy present") >> comfy
