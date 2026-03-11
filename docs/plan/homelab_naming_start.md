3. How to Model Your Hyper‑V → Ubuntu → Docker → K3s Stack in NetBox
Here’s the structure I recommend — clean, scalable, and future‑proof.

Sites
Code
homelab
Device Roles
Code
hyperv-host
k3s-master
k3s-worker
traefik-node
llm-node
docker-node
Platforms
Code
windows-server-2022
ubuntu-22-04
ubuntu-24-04
Tags
Code
hyperv
k3s
docker
traefik
llm
control-plane
worker
Naming Scheme
You’ll love this — it’s deterministic and machine‑friendly:

Code
<env>-<provider>-<role>-<index>
Examples:

Code
lab-hv-k3s-master-01
lab-hv-k3s-worker-01
lab-hv-traefik-01
lab-hv-llm-01