"""What studio resource kinds are, and how they depend on Automatic1111."""

from diagrams import Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.5", "ranksep": "0.7"}

with Diagram(
    "Automatic1111 resources and dependencies — generic meanings",
    filename="automatic1111-resources-dependencies",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")
    config = Server("Studio profile\nhosts + pipeline map")
    coaching = Server("Coaching prompts\nchat system instructions")
    presets = Server("Still style presets\nreusable prompt templates")
    negatives = Server("Negative presets\navoid-this cue lists")
    examples = Server("Smoke examples\npaste-ready first stills")
    share = Server("Lab share\ndeployed working set")
    chat = Docker("Chat path\nLiteLLM + Ollama")
    webui = Docker("Images client\nOpen WebUI")
    a1111 = Server("Automatic1111\ntxt2img / img2img API")
    models = Server("Checkpoints on host\nSD-class + ControlNet")
    ui = Client("A1111 Web UI")

    operator >> webui >> Edge(label="sdapi") >> a1111
    operator >> ui >> a1111
    operator >> chat >> coaching
    config >> Edge(label="names still pipeline") >> presets
    config >> coaching
    presets >> share
    negatives >> share
    examples >> share
    coaching >> Edge(label="writes prompts for") >> presets
    share >> Edge(label="paste / upload") >> a1111
    models >> a1111
