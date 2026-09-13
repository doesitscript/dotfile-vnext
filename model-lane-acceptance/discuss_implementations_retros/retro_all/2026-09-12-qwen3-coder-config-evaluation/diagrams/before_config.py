#!/usr/bin/env python3
"""Before: token cup overflows + two embed owners. SVG-only product."""
from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.client import User
from diagrams.onprem.network import Nginx
from diagrams.onprem.compute import Server
from diagrams.onprem.database import Postgresql

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "BEFORE — cup overflows (32k full)",
    filename="before_config",
    show=False,
    outformat="svg",
    graph_attr=graph_attr,
):
    you = User("You\n(Continue chat)")

    with Cluster("Continue asks for"):
        prompt = Postgresql("Prompt\n~24,577 tokens")
        answer_room = Server("Reserve answer\nmaxTokens 8192")

    gateway = Nginx("LiteLLM\nqwen3-coder-30b-a3b\nrep=1.0\nno input/output caps")
    brain = Server("vLLM cup\nmax-model-len\n32768")

    with Cluster("Embed confusion"):
        embed_gw = Server("Gateway embed\nnomic-embed-text")
        embed_local = Server("LM Studio embed\nalso wants embed")

    you >> Edge(label="chat") >> prompt
    prompt >> answer_room
    answer_room >> Edge(label="24577+8192=32769\nOVERFLOW!", color="red") >> gateway
    gateway >> Edge(label="rejects", color="red") >> brain
    you >> Edge(label="two embeds?") >> embed_gw
    you >> embed_local
