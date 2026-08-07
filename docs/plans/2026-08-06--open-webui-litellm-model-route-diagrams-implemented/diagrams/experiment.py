"""experiment — LiteLLM smoke alias → Ornith primary (OI tag experiment)."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.container import Docker

with Diagram(
    "experiment route",
    filename="experiment",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    oi = Client("Open WebUI\nOI tag experiment")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("alias experiment\nlocal smoke")
    with Cluster("k3s-02 vLLM"):
        vllm = Docker("shares Ornith\nvllm-primary")
    op >> oi >> Edge(label="model=experiment") >> gw >> vllm
