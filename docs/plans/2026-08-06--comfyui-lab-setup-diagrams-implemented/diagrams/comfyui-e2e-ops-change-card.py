"""E2E Solution 1 — Homelab ops change-card illustrator."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.k8s.compute import Deploy
from diagrams.k8s.storage import PVC
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "E2E 1 — Ops change-card pipeline",
    filename="comfyui-e2e-ops-change-card",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("Brief"):
        issue = Server("Plan packet / PR\nchange notes")
        webui = Docker("Open WebUI chat")
        litellm = Docker("LiteLLM coaching")
        ollama = Server("Desktop Ollama\nbrief writer")

    with Cluster("Illustrate"):
        comfy = Deploy("ComfyUI\nchange-card graph")
        models = PVC("Checkpoint volume")
        share = Server("Lab share\ncards/out")

    dest = Client("Attach to plan\nor GitHub issue")

    operator >> issue >> webui >> litellm >> ollama
    ollama >> Edge(label="card brief") >> comfy
    operator >> Edge(label="optional tweak") >> comfy
    models >> comfy
    comfy >> share >> dest
