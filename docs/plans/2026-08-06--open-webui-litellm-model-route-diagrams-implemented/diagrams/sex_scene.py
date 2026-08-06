"""sex_scene — LiteLLM alias → desktop Ollama Gemma4 uncensored."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "sex_scene route",
    filename="sex_scene",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    owui = Client("Open WebUI\nmodel=sex_scene")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\nalias sex_scene")
    with Cluster("dev-workstation-win"):
        ollama = Server("Ollama\ngemma4-12b-uncensored-1.5m")
    op >> owui >> Edge(label="chat") >> gw >> Edge(label="ollama/") >> ollama
