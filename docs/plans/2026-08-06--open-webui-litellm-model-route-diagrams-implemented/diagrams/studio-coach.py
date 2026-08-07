"""studio-coach — LiteLLM coaching alias → desktop Gemma4 vision."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "studio-coach route",
    filename="studio-coach",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    owui = Client("Open WebUI\nprompt coach")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\nstudio-coach")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\ngemma4:12b")
    with Cluster("Pixels (not this route)"):
        a1111 = Server("A1111\nCyberRealistic")
        comfy = Server("ComfyUI\nFLUX+SDXL")
    op >> owui >> gw >> Edge(label="vision coach") >> ollama
    owui >> Edge(label="Images UI", style="dashed") >> a1111
    owui >> Edge(label="Phase B", style="dashed") >> comfy
