"""default — LiteLLM local-first default alias → Ornith (vLLM)."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.container import Docker

with Diagram(
    "default route",
    filename="default",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    oi = Client("Open WebUI\nOI tag default")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("alias default\nlocal-primary")
    with Cluster("k3s-02 vLLM"):
        vllm = Docker("Ornith\nvllm-primary")
    op >> oi >> Edge(label="model=default") >> gw >> vllm
