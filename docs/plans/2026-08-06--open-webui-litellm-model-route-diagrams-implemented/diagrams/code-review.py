"""code-review — LiteLLM review alias → Ornith primary on vLLM."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import User
from diagrams.onprem.client import Client
from diagrams.onprem.container import Docker

with Diagram(
    "code-review route",
    filename="code-review",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"pad": "0.35", "nodesep": "0.5", "ranksep": "0.65"},
):
    op = User("Operator")
    client = Client("Codex / Continue\nreview flow")
    with Cluster("k3s-02 LiteLLM"):
        gw = Docker("alias code-review\nlocal review")
    with Cluster("k3s-02 vLLM"):
        vllm = Docker("Ornith\nvllm-primary")
    op >> client >> Edge(label="model=code-review") >> gw >> vllm
