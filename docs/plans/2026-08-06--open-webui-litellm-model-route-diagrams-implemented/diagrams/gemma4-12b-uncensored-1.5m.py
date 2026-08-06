"""gemma4-12b-uncensored-1.5m — LiteLLM alias → desktop Ollama."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "gemma4-12b-uncensored-1.5m route",
    filename="gemma4-12b-uncensored-1.5m",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    owui = Client("Open WebUI\n(+ Arena pin)")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\ngemma4-12b-uncensored-1.5m")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\nsatgeze/gemma4-…")
    op >> owui >> gw >> Edge(label="vision-capable") >> ollama
