"""arena — Open WebUI evaluation arena pinned to gemma4-12b."""

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
        pin = Client("Pinned IDs\ngemma4-12b\npositive-negative-prompt-assist")
    with Cluster("LiteLLM + desktop"):
        gw = Docker("litellm.hom.lab")
        ollama = Server("Ollama desktop\ngemma4:12b")
    op >> owui >> pin >> gw >> ollama
