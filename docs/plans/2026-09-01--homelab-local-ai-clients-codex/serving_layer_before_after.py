# Concurrent-work note: Codex owns this rendered serving-layer visual; Cursor should not rewrite it.
"""Render the Codex deep-lane serving layer before and after its tool-call repair."""

from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.client import Client
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker
from diagrams.programming.language import Python


GRAPH_ATTR = {"pad": "0.8", "nodesep": "0.7", "ranksep": "0.9"}


with Diagram(
    "Before: tool-shaped text could not become a Codex action",
    filename="serving-layer-before",
    show=False,
    direction="LR",
    outformat="png",
    graph_attr=GRAPH_ATTR,
):
    with Cluster("Developer workstation"):
        request = Client("You ask Codex\nto read a file")
        codex = Client("Codex CLI\nlocal-deep profile")

    with Cluster("k3s-02 gateway"):
        gateway = Docker("LiteLLM gateway\nResponses API")

    with Cluster("RTX 5090 vLLM serving pod"):
        model = Server("Qwen2.5-Coder\n32B AWQ")
        old_parser = Python("old tool parser\nexpects another tag style")
        missed = Server("plain text\nno tool_calls")

    request >> codex >> Edge(label="Responses request") >> gateway
    gateway >> Edge(label="model request") >> model
    model >> Edge(label="JSON-like request") >> old_parser
    old_parser >> Edge(label="format not recognized") >> missed


with Diagram(
    "After: matched serving components emit structured tool calls",
    filename="serving-layer-after",
    show=False,
    direction="LR",
    outformat="png",
    graph_attr=GRAPH_ATTR,
):
    with Cluster("Developer workstation"):
        request = Client("You ask Codex\nto read a file")
        codex = Client("Codex CLI\nlocal-deep profile")

    with Cluster("k3s-02 gateway"):
        gateway = Docker("LiteLLM gateway\nResponses API")

    with Cluster("RTX 5090 vLLM serving pod"):
        template = Python("paired chat template\nuses <tools> envelope")
        model = Server("Qwen2.5-Coder\n32B AWQ")
        parser = Python("custom tool parser\ncreates structured tool_calls")

    with Cluster("Codex verification gate"):
        runner = Server("Codex exec runner\ncan receive a tool call")
        result = Server("current local proof\nstill required")

    request >> codex >> Edge(label="Responses request") >> gateway
    gateway >> template >> Edge(label="prompt") >> model
    model >> Edge(label="<tools> payload") >> parser
    parser >> Edge(label="structured tool call") >> runner >> result
