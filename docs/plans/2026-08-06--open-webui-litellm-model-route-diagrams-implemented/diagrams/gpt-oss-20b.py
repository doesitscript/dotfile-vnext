"""gpt-oss-20b — LiteLLM alias → desktop Ollama gpt-oss:20b."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "gpt-oss-20b route",
    filename="gpt-oss-20b",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    owui = Client("Open WebUI chat")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\ngpt-oss-20b")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\ngpt-oss:20b")
    op >> owui >> gw >> Edge(label="general/reasoning") >> ollama
