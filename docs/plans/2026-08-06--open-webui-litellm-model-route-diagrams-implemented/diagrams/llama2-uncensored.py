"""llama2-uncensored — LiteLLM alias → desktop Ollama."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "llama2-uncensored route",
    filename="llama2-uncensored",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    owui = Client("Open WebUI\nllama2-uncensored")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\nalias llama2-uncensored")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\nllama2-uncensored")
    op >> owui >> gw >> Edge(label="ollama/") >> ollama
