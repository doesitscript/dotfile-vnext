"""qwen3.6-27b — LiteLLM alias → desktop Ollama qwen3.6:27b."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "qwen3.6-27b route",
    filename="qwen3.6-27b",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    owui = Client("Open WebUI chat")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\nqwen3.6-27b")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\nqwen3.6:27b")
    op >> owui >> gw >> Edge(label="agentic/thinking") >> ollama
