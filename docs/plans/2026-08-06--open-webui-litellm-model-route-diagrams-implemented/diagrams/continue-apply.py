"""continue-apply — Continue apply alias → HVH-01 Ollama phi4-mini."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "continue-apply route",
    filename="continue-apply",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    client = Client("Continue\napply flow")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("litellm\ncontinue-apply")
    with Cluster("HOM-LAB-HVH-01"):
        ollama = Server("Ollama\nphi4-mini")
    op >> client >> gw >> Edge(label="apply helper") >> ollama
