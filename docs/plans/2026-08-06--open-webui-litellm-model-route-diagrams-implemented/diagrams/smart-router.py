"""smart-router — LiteLLM complexity auto-router tiers."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

with Diagram(
    "smart-router route",
    filename="smart-router",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.45", "ranksep": "0.6"},
):
    op = User("Operator")
    client = Client("Client\nmodel=smart-router")
    with Cluster("LiteLLM complexity_router"):
        gw = Docker("smart-router")
        simple = Server("SIMPLE\n→ code-review")
        med = Server("MEDIUM+\n→ Ornith")
        cloud = Server("COMPLEX*\n→ gpt-4o/Claude")
    with Cluster("k3s-02 vLLM"):
        vllm = Docker("vllm-primary")
    op >> client >> gw
    gw >> simple >> vllm
    gw >> med >> vllm
    gw >> Edge(label="if cloud keys", style="dashed") >> cloud
