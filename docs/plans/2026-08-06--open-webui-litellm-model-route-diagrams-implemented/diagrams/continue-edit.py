"""continue-edit — Continue chat/edit alias → desktop Ollama qwen3-coder:30b."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "continue-edit route",
    filename="continue-edit",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    client = Client("Continue\nchat + edit")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\ncontinue-edit")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\nqwen3-coder:30b")
    op >> client >> gw >> Edge(label="desktop AMD route") >> ollama
