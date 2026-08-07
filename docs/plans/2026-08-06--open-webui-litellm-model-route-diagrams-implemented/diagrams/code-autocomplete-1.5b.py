"""code-autocomplete-1.5b — Continue autocomplete alias → HVH-01 Ollama 1.5B."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "code-autocomplete-1.5b route",
    filename="code-autocomplete-1.5b",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    client = Client("Continue\nexplicit autocomplete")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\ncode-autocomplete-1.5b")
    with Cluster("HOM-LAB-HVH-01"):
        ollama = Server("Ollama\nqwen2.5-coder:1.5b")
    op >> client >> gw >> Edge(label="GTX 1060 / llama.cpp") >> ollama
