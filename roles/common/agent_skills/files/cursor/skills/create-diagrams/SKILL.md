---
name: create-diagrams
description: Generate architecture diagrams as Python code using the `diagrams` library (https://diagrams.mingrammer.com). Produces runnable .py scripts that render PNG/SVG diagrams using Graphviz. Use when the user asks to create, draw, or visualize architecture diagrams, cloud infrastructure, system diagrams, network diagrams, AWS/GCP/Azure/Kubernetes architecture, or any infrastructure-as-diagram request. Also use when the user asks to update or modify an existing diagram script.
---

# Create Architecture Diagrams

Uses the `diagrams` Python library at `/Users/joshc/develop/diagrams`.

## Prerequisites

```bash
brew install graphviz        # if not installed
pip install diagrams
```

## Output convention

- Always use `show=False` unless the user asks to auto-open
- Default `outformat="png"`; support `svg`, `pdf`, `jpg` on request
- Save scripts to the user's working directory or a path they specify
- Run with: `python <script>.py`

## Core imports

```python
from diagrams import Diagram, Cluster, Edge
```

## Providers and key modules

| Provider | Import prefix | Common modules |
|---|---|---|
| AWS | `diagrams.aws` | `compute`, `database`, `network`, `storage`, `integration`, `analytics`, `ml`, `management`, `security` |
| GCP | `diagrams.gcp` | `compute`, `database`, `analytics`, `network`, `storage`, `iot` |
| Azure | `diagrams.azure` | `compute`, `database`, `network`, `storage`, `integration` |
| Kubernetes | `diagrams.k8s` | `compute`, `network`, `storage`, `clusterconfig`, `rbac` |
| On-Prem | `diagrams.onprem` | `compute`, `database`, `network`, `queue`, `monitoring`, `inmemory`, `analytics`, `logging`, `container`, `ci`, `cd`, `iac` |
| Generic | `diagrams.generic` | `compute`, `database`, `network`, `storage`, `os` |
| SaaS | `diagrams.saas` | `chat`, `cdn`, `filesharing`, `identity`, `logging`, `media`, `recommendation`, `social` |

Browse full node lists: `/Users/joshc/develop/diagrams/docs/nodes/`

## Diagram patterns

### Simple flow
```python
with Diagram("Web Service", show=False):
    ELB("lb") >> EC2("web") >> RDS("db")
```

### Fan-out to grouped workers
```python
with Diagram("Grouped Workers", show=False, direction="TB"):
    ELB("lb") >> [EC2("w1"), EC2("w2"), EC2("w3")] >> RDS("events")
```

### Clusters (logical grouping)
```python
with Diagram("Clustered App", show=False):
    dns = Route53("dns")
    lb  = ELB("lb")

    with Cluster("Services"):
        svcs = [ECS("web1"), ECS("web2")]

    with Cluster("DB Cluster"):
        db = RDS("primary")
        db - [RDS("replica")]

    dns >> lb >> svcs >> db
```

### Nested clusters
```python
with Cluster("Event Flows"):
    with Cluster("Workers"):
        workers = [ECS("w1"), ECS("w2")]
    with Cluster("Processing"):
        handlers = [Lambda("fn1"), Lambda("fn2")]
```

### Styled edges
```python
from diagrams import Edge

# labeled, colored, dashed
A >> Edge(label="events", color="firebrick", style="dashed") >> B
# bidirectional (undirected)
A - B
# reverse arrow
A << B
```

Edge `style` values: `solid` (default), `dashed`, `dotted`, `bold`

### Custom graph appearance
```python
graph_attr = {"fontsize": "14", "bgcolor": "transparent"}
with Diagram("My Diagram", show=False, graph_attr=graph_attr):
    ...
```

### Custom node (arbitrary icon)
```python
from diagrams.custom import Custom
Custom("RabbitMQ", "rabbitmq.png")
```

## Workflow — full end-to-end (agent does all of this)

1. Clarify the architecture with the user if the request is vague
2. **Check deps** — run both checks; install anything missing:
   ```bash
   which dot || brew install graphviz
   python3 -c "import diagrams" 2>/dev/null || pip3 install diagrams
   ```
3. **Write the script** — save to a sensible path (e.g. `~/Desktop/<name>.py` or a path the user specifies)
4. **Run it**:
   ```bash
   python3 <path/to/script>.py
   ```
5. **Report the output** — tell the user the full path to the generated PNG so they can open it:
   ```
   Diagram saved: ~/Desktop/my_diagram.png
   ```
6. If the script errors, fix and re-run automatically before reporting back

## Reference files

- Full examples: `/Users/joshc/develop/diagrams/docs/getting-started/examples.md`
- Node browser (AWS): `/Users/joshc/develop/diagrams/docs/nodes/aws.md`
- Node browser (all providers): `/Users/joshc/develop/diagrams/docs/nodes/`
- Diagram options guide: `/Users/joshc/develop/diagrams/docs/guides/diagram.md`
- Cluster guide: `/Users/joshc/develop/diagrams/docs/guides/cluster.md`
- Edge guide: `/Users/joshc/develop/diagrams/docs/guides/edge.md`
