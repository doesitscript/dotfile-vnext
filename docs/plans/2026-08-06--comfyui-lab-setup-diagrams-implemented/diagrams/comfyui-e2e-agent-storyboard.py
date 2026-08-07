"""E2E Solution 2 — Multi-agent session storyboard stills."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.k8s.compute import Deploy
from diagrams.k8s.storage import PVC
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "E2E 2 — Agent-run storyboard pipeline",
    filename="comfyui-e2e-agent-storyboard",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("Session truth"):
        cursor = Client("Cursor / Codex\nsession")
        langfuse = Docker("Langfuse trace\n(optional)")
        summary = Server("Role timeline\nplanner→exec")

    with Cluster("Frame briefs"):
        webui = Docker("Open WebUI chat")
        litellm = Docker("LiteLLM\nframe coach")
        ollama = Server("Desktop Ollama")

    with Cluster("Still sequence"):
        comfy = Deploy("ComfyUI\nstoryboard graph")
        models = PVC("Checkpoint volume")
        share = Server("Lab share\nstoryboards/out")

    dest = Client("Demo / retro\nwrite-up")

    operator >> cursor >> summary
    langfuse >> Edge(style="dashed") >> summary
    summary >> webui >> litellm >> ollama
    ollama >> Edge(label="N frame prompts") >> comfy
    models >> comfy
    comfy >> share >> dest
