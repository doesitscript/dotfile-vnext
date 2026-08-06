"""What studio resource kinds are, and how they depend on ComfyUI."""

from diagrams import Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.k8s.compute import Deploy
from diagrams.k8s.storage import PVC
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.5", "ranksep": "0.7"}

with Diagram(
    "ComfyUI resources and dependencies — generic meanings",
    filename="comfyui-resources-dependencies",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")
    config = Server("Studio profile\nhosts + pipeline map")
    coaching = Server("Coaching prompts\nchat system instructions")
    presets = Server("Style presets\nreusable prompt templates")
    negatives = Server("Negative presets\navoid-this cue lists")
    examples = Server("Smoke examples\npaste-ready first runs")
    graphs = Server("Workflow graphs\nsaved node recipes")
    adapters = Server("Adapter slots\nfuture LoRA catalog")
    share = Server("Lab share\ndeployed working set")
    chat = Docker("Chat path\nLiteLLM + Ollama")
    comfy = Deploy("ComfyUI runtime\nstill + motion graphs")
    models = PVC("Checkpoint volume\nweights on GPU host")
    ui = Client("ComfyUI web / API")

    operator >> ui >> comfy
    operator >> chat >> coaching
    config >> Edge(label="names pipelines") >> presets
    config >> coaching
    config >> graphs
    presets >> share
    negatives >> share
    examples >> share
    graphs >> Edge(label="load into") >> comfy
    coaching >> Edge(label="writes prompts for") >> presets
    share >> Edge(label="inputs / outputs") >> comfy
    adapters >> Edge(label="pending research", style="dashed") >> models
    models >> comfy
