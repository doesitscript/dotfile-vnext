"""Lab Automatic1111 architecture — Phase A stills on HVH-01."""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.general import Client, User
from diagrams.onprem.compute import Server
from diagrams.onprem.container import Docker

graph_attr = {"pad": "0.4", "nodesep": "0.55", "ranksep": "0.7"}

with Diagram(
    "Lab Automatic1111 — HVH-01 Phase A",
    filename="automatic1111-lab-architecture",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr=graph_attr,
):
    operator = User("Operator")

    with Cluster("hom-lab-ctl-dkr-02"):
        webui = Docker("Open WebUI\n:3080 Images")

    with Cluster("HOM-LAB-HVH-01 · GTX 1060"):
        a1111 = Server("Automatic1111\na1111-hvh01.hom.lab:7860")
        models = Server("Model files\nCyberRealistic + OpenPose")

    ansible = Server("Ansible\ndeploy_automatic1111")
    direct = Client("A1111 Web UI\n(direct)")

    operator >> Edge(label="Image button") >> webui
    webui >> Edge(label="sdapi") >> a1111
    operator >> Edge(label="denoise / OpenPose") >> direct
    direct >> a1111
    a1111 >> models
    ansible >> Edge(label="present|absent") >> a1111
