#!/usr/bin/env python3
"""After: smaller answer reserve + one embed owner. SVG-only product."""
from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.client import User
from diagrams.onprem.network import Nginx
from diagrams.onprem.compute import Server
from diagrams.onprem.database import Postgresql

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "AFTER — cup fits (room left in 32k)",
    filename="after_config",
    show=False,
    outformat="svg",
    graph_attr=graph_attr,
):
    you = User("You\n(Continue chat)")

    with Cluster("Continue asks for"):
        prompt = Postgresql("Prompt\n~24,577 tokens")
        answer_room = Server("Reserve answer\nmaxTokens 4096")

    gateway = Nginx(
        "LiteLLM\nqwen3-coder-30b-a3b\nrep=1.05\nmax_in 28672\nmax_out 4096"
    )
    brain = Server("vLLM cup\nmax-model-len\n32768\n(unchanged)")

    with Cluster("One embed owner"):
        embed_gw = Server("Gateway embed\nnomic-embed-text")
        embed_off = Server("LM Studio embed\nenabled: false")

    you >> Edge(label="chat") >> prompt
    prompt >> answer_room
    answer_room >> Edge(label="24577+4096=28673\nFITS", color="darkgreen") >> gateway
    gateway >> Edge(label="ok", color="darkgreen") >> brain
    you >> Edge(label="sole embed") >> embed_gw
    embed_off >> Edge(label="skipped", style="dashed") >> embed_gw
