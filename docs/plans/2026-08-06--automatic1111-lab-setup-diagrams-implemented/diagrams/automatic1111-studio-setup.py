"""Automatic1111 place in the creative studio — generic roles."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.75"}

with Diagram(
    "Automatic1111 studio setup — roles and surfaces",
    filename="automatic1111-studio-setup",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("Chat and coaching"):
        webui = Docker("Chat UI\nOpen WebUI")
        litellm = Docker("Chat gateway\nLiteLLM")
        ollama = Server("Desktop chat runtime\nOllama coaching")

    with Cluster("Phase A stills"):
        images = Docker("Images button\nOpen WebUI")
        a1111 = Server("Still pixel backend\nAutomatic1111")
        direct = Client("Direct Web UI\ndenoise / ControlNet")
        models = Server("Local checkpoints\n+ ControlNet packs")

    with Cluster("Studio working set"):
        share = Server("Lab share\npresets / in / out")
        catalog = Server("Model catalog\nweights inventory")

    ansible = Server("Ansible lifecycle\npresent|absent")
    comfy = Server("Phase B ComfyUI\n(advanced / motion)")

    operator >> webui >> litellm >> ollama
    operator >> Edge(label="still generate") >> images >> Edge(label="sdapi") >> a1111
    operator >> direct >> a1111
    a1111 >> models
    a1111 >> share
    catalog >> models
    ansible >> a1111
    a1111 >> Edge(label="later stills / video", style="dashed") >> comfy
