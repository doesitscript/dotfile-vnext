"""K3s-02 safety and ownership boundaries — host vs guest vs non-goals."""

from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.compute import Server


with Diagram(
    "K3s-02 storage safety boundaries",
    filename="storage-safety-boundaries",
    direction="TB",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"ranksep": "1.0", "nodesep": "0.6"},
):
    with Cluster("Authorized host operation"):
        serial = Server("Serial-bound SSD workflow\nexact serial discovery")
        wipe = Server("Wipe + format\nonly named SSDs")
        volumes = Server("F: logs | G: cache | H: cold\nindependent NTFS volumes")
        serial >> wipe >> volumes

    with Cluster("Guest storage contracts"):
        root = Server("Root disk\nOS + control plane")
        k3s = Server("K3s\nmounts are label-bound")
        cache = Server("Cache disk\ncontainerd, PVCs, HF")
        logs = Server("Logs disk\npod logs")
        root >> k3s
        cache >> Edge(label="LABEL=k3s-cache") >> k3s
        logs >> Edge(label="LABEL=k3s-logs") >> k3s

    with Cluster("Explicit non-goals"):
        no_raid = Server("No RAID0\nno striped failure domain")
        no_pass = Server("No SSD passthrough\nVHDX guest path remains")
        no_durable = Server("No durable state\non ephemeral cache alone")

    volumes >> Edge(label="host-only; not guest-mounted") >> no_pass
    volumes >> Edge(label="separate filesystem") >> cache
    volumes >> Edge(label="separate filesystem") >> logs
    no_raid >> Edge(label="policy boundary", style="dashed") >> k3s
    no_durable >> Edge(label="policy boundary", style="dashed") >> cache
