"""E2E Solution 2 — ControlNet reference-locked UI / topology mock."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker


graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "E2E 2 — ControlNet reference-locked mock",
    filename="automatic1111-e2e-controlnet-mock",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("Reference"):
        shot = Client("UI screenshot\nor wireframe")
        layout = Server("Layout / pose\nlock intent")

    with Cluster("Coach (optional)"):
        webui = Docker("Open WebUI chat")
        litellm = Docker("LiteLLM")
        ollama = Server("Desktop Ollama\nprompt polish")

    with Cluster("Phase A ControlNet"):
        direct = Client("A1111 Web UI\nimg2img + OpenPose")
        a1111 = Server("Automatic1111\nHVH-01 GTX 1060")
        cn = Server("ControlNet packs\nOpenPose / softedge")
        share = Server("Lab share\nmocks/out")

    dest = Client("Design review\n/ capacity note")

    operator >> shot >> layout
    layout >> Edge(label="optional") >> webui >> litellm >> ollama
    ollama >> Edge(label="prompt", style="dashed") >> direct
    operator >> Edge(label="denoise / CN knobs") >> direct
    direct >> a1111
    cn >> a1111
    shot >> Edge(label="init image") >> a1111
    a1111 >> share >> dest
