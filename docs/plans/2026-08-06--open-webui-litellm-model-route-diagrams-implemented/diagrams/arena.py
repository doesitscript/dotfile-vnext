"""arena — Open WebUI evaluation arena pinned to Gemma4 uncensored."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "arena route",
    filename="arena",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    with Cluster("hom-lab-ctl-dkr-02"):
        owui = Docker("Open WebUI\nArena enabled")
        pin = Client("Pinned ID\ngemma4-12b-uncensored-1.5m")
    with Cluster("LiteLLM + desktop"):
        gw = Docker("litellm.hom.lab")
        ollama = Server("Ollama desktop\nGemma4 uncensored")
    op >> owui >> pin >> gw >> ollama
