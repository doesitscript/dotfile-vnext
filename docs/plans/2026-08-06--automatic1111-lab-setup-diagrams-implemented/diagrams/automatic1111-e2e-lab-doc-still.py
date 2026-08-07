"""E2E Solution 1 — Open WebUI Images lab-doc still (Phase A happy path)."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker


graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "E2E 1 — Lab-doc still via Open WebUI Images",
    filename="automatic1111-e2e-lab-doc-still",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("Brief"):
        notes = Server("Runbook / NetBox\n/ plan notes")
        webui = Docker("Open WebUI chat\nstudio-coach")
        litellm = Docker("LiteLLM\ncoaching only")
        ollama = Server("Desktop Ollama\nbrief writer")

    with Cluster("Phase A still"):
        images = Docker("Open WebUI\nImages button")
        a1111 = Server("Automatic1111\nsdapi txt2img")
        models = Server("CyberRealistic\nSD1.5 on HVH-01")
        share = Server("Lab share\ndocs/stills/out")

    dest = Client("Embed in plan\nissue / runbook")

    operator >> notes >> webui >> litellm >> ollama
    ollama >> Edge(label="still brief") >> images
    operator >> Edge(label="Images") >> images
    images >> Edge(label="sdapi") >> a1111
    models >> a1111
    a1111 >> share >> dest
