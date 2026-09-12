"""K3s-02 bounded cutover flow — applied order with retain/rollback edges."""

from diagrams import Diagram, Edge
from diagrams.onprem.compute import Server


with Diagram(
    "K3s-02 storage cutover flow",
    filename="storage-cutover-flow",
    direction="LR",
    show=False,
    outformat=["png", "svg", "dot"],
    graph_attr={"ranksep": "0.9", "nodesep": "0.55"},
):
    start = Server("Existing K3s node\nroot-backed workloads")
    prep = Server("Prepare filesystems\nlabels + fstab\nLABEL=k3s-cache/logs")
    copy = Server("Copy + verify\nchecksums / capacity")
    bind = Server("Apply bindings\ncontainerd + PVC path")
    logs = Server("Configure pod logs\nnative podLogsDir")
    validate = Server("Validate\nReady, pressure, mounts")
    cleanup = Server("Cleanup stale data\nfree root capacity")
    steady = Server("Steady state\nroot 21%; cache 29%; logs ~1%")

    retain = Server("failure: retain source")
    rollback = Server("failure: rollback bindings")

    start >> prep >> copy >> bind >> logs >> validate >> cleanup >> steady
    copy >> Edge(label="abort", style="dashed", color="firebrick") >> retain
    bind >> Edge(label="abort", style="dashed", color="firebrick") >> rollback
    validate >> Edge(label="fail gate", style="dashed", color="firebrick") >> rollback
