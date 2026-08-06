"""default — LiteLLM migration/fallback alias (OI tag default)."""

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
        gw = Docker("alias default\nmigration row")
        policy = Docker("routing_policy\nlocal-default-fallback")
    op >> oi >> Edge(label="model=default") >> gw >> policy
