Getting Started with K3s: A Practical Guide to Setup and Scaling
Joseph Whiteaker
Joseph Whiteaker

Follow
6 min read
·
Feb 17, 2025

Listen


Share


More

Press enter or click to view image in full size

k3s logo
K3s is a lightweight, easy-to-install Kubernetes distribution designed for simplicity and efficiency. Whether you’re setting up a single-node cluster for development or building a multi-node, highly available environment, this guide will walk you through the essential steps to get started with K3s and scale it effectively.

This post serves as both an introductory guide for those new to K3s and a quick reference for those already familiar with it. We’ll cover installation, adding server and worker nodes, configuring load balancing, etc…

Installing K3s
Understanding K3s Nodes
Server Node: Equivalent to a control plane node in Kubernetes, responsible for running the API server, scheduler, and controllers.
Agent Node: Equivalent to a worker node, responsible for running workloads and handling pod scheduling.
⚠️ Please just make your life easy and disable firewall on all of the nodes for now if you’re new to k3s and not sure what ports to keep and all that.

Quick Installation
K3s is designed to run on almost any Linux system with minimal requirements. To set up a single-node cluster, simply run:

curl -sfL https://get.k3s.io | sh -
This script will:
✅ Download and install the K3s binaries
✅ Configure systemd services
✅ Generate required node token
✅ Set up a Kubeconfig file

Press enter or click to view image in full size

k3s service in cockpit ui
Key Configuration Files
After installation, these are the most important files in your K3s setup that are generated:

Kubeconfig file for accessing the cluster

/etc/rancher/k3s/k3s.yaml 
Token used to join additional nodes

/etc/rancher/k3s/server/node-token
Main K3s configuration file

/etc/rancher/k3s/config.yaml 
This will generate a systemd file located at

/etc/systemd/system/k3s.service
And an environment variable file will be created at

/etc/systemd/system/k3s.service.env
The k3s service should look something along the lines of this

[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/%N
EnvironmentFile=-/etc/sysconfig/%N
EnvironmentFile=-/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yess
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=/bin/sh -xc '! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service 2>/dev/null'
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s \
    server \
Press enter or click to view image in full size

k3s files in /etc/systemd/system
Accessing Your K3s Cluster Remotely
To manage the cluster from another machine, copy the Kubeconfig file to your local system:

# Run this on your workstation or bastion server
export SERVER_IP=<server-ip>
scp user@$SERVER_IP:/etc/rancher/k3s/k3s.yaml ~/.kube/config && \
sed -i "s/127.0.0.1/$SERVER_IP/g" ~/.kube/config && \
export KUBECONFIG=~/.kube/config
You should now be able to interact with your K3s cluster using kubectl:

kubectl get nodes
Scaling Up: Adding More Server Nodes
Why Add Additional Servers?
A single-node setup is fine for development, but in a production-like environment, adding extra server nodes increases availability and redundancy.

Joining a New Server Node
On a new server node, first retrieve the cluster token from the first server (master-1):

export K3S_TOKEN=$(ssh user@$SERVER_IP "sudo -S cat /var/lib/rancher/k3s/server/node-token")
Then, install K3s on the second server (server-2) using the token:

curl -sfL https://get.k3s.io | sh -s - server --server https://$SERVER_IP:6443 --token $K3S_TOKEN
Configuring the New Server Node (/etc/rancher/k3s/config.yaml)
write-kubeconfig-mode: "644"  # Allows all users to read kubeconfig
tls-san:
  - "10.10.10.100"  # IP of the load balancer (if used)
disable:
  - servicelb  # Disables the default K3s load balancer
  - traefik    # Disables the built-in ingress controller
server: "https://$SERVER_IP:6443"  # Points to the existing K3s server or LB
Restart K3s to apply the changes:

systemctl restart k3s
Once complete, verify that both servers are active:

kubectl get nodes
You should see both server-1 and server-2 in the cluster.

Adding Worker/Agent Nodes to the Cluster
Worker nodes handle the actual workloads in the cluster. To add a worker node, retrieve the node token from any server node and install k3s in agent mode:

export SERVER_IP="<your-ip>"
export USER="<your-user>"

export K3S_TOKEN=$(ssh $USER@$SERVER_IP "sudo -S cat /etc/rancher/server/node-token")

echo "K3S_TOKEN: $K3S_TOKEN"

# Then, install K3s in agent mode:
curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$K3S_TOKEN sh -
Verify that the worker node has joined on your workstation:

kubectl get nodes
You should now see both server and worker nodes in the cluster.

Restarting and Uninstalling K3s
Restart K3s
# Server Node
systemctl restart k3s

# Agent Node
systemctl restart k3s-agent
Uninstall K3s
# Server Node
/usr/local/bin/k3s-uninstall.sh

# Agent node
/usr/local/bin/k3s-agent-uninstall.sh
Setting Up an NGINX Load Balancer for K3s API Access
For a highly available control plane, it’s best to use a load balancer that distributes traffic between multiple K3s servers. So these instructions are assuming you have 1 server node setup and are setting up your kubectl load balancer vm or container.

Step 1: Install NGINX on a Load Balancer Node (lb-1)
Create an NGINX configuration file (nginx.conf):

events {}

stream {
  upstream k3s_servers {
    server 10.10.10.50:6443;  # First K3s server node
  }

  server {
    listen 6443;
    proxy_pass k3s_servers;
  }
}
Step 2: Start the NGINX Load Balancer
Option 1: Run as a Docker container

docker/podman run -d --restart unless-stopped \
    -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf \
    -p 6443:6443 \
    nginx:stable
Option 2: Install and run NGINX manually

cp nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx
Now, agents and kubectl can connect via the load balancer (10.10.10.100).

Step 3: Update K3s Config to Accept Load Balancer Traffic
Modify /etc/rancher/k3s/config.yaml on all server nodes

tls-san:
  - "10.10.10.100"  # Load balancer IP
Restart K3s on each server:

systemctl restart k3s
Step 4: Add the Second Server Node & Update NGINX
Once the second server node (server-2) is up and running, update the NGINX configuration to distribute traffic across both servers:

events {}
stream {
  upstream k3s_servers {
    server 10.10.10.50:6443;  # master-1
    server 10.10.10.51:6443;  # master-2
  }
server {
    listen 6443;
    proxy_pass k3s_servers;
  }
}
Restart NGINX to apply the changes:

systemctl restart nginx
Running K3s in Docker / Docker Compose
For a more portable and ephemeral setup, K3s can be run inside a Docker container instead of directly on a host system. This is useful for testing, CI/CD environments, and running Kubernetes clusters without modifying the underlying OS.

Running K3s in Docker
To start a K3s server inside a Docker container:

sudo docker run \
  --privileged \
  --name k3s-server-1 \
  --hostname k3s-server-1 \
  -p 6443:6443 \
  -d rancher/k3s:v1.24.10-k3s1 \
  server
Explanation:

--privileged → Grants the container full access to the host system (required for K3s).
--name k3s-server-1 → Assigns a name to the container.
--hostname k3s-server-1 → Sets the container’s hostname.
-p 6443:6443 → Exposes the Kubernetes API server port for external access.
-d rancher/k3s:v1.24.10-k3s1 server → Runs the latest stable K3s version in server mode.
Using K3d: A Dev-Friendly Way to Run K3s in Containers
K3d is a lightweight wrapper around K3s that runs Kubernetes clusters inside Docker containers. It provides an opinionated way to spin up multi-node K3s clusters quickly, making it an ideal choice for local development and CI/CD environments.

Installing K3d
Install K3d via their official script:

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
Or use Homebrew (Mac/Linux):

brew install k3d
Creating a K3s Cluster with K3d
To create a single-node cluster:

k3d cluster create my-cluster
For a multi-node setup with 1 server + 2 worker nodes:

k3d cluster create my-cluster --servers 1 --agents 2
Check the running cluster:

kubectl get nodes
Deleting a K3d Cluster
k3d cluster delete my-cluster
Conclusion
K3s makes Kubernetes lightweight, fast, and easy to manage, whether for a single-node setup or a multi-node cluster. This guide covered installation, scaling, load balancing, and running K3s in Docker or K3d for development and CI/CD.

With these steps, you now have a functional K3s cluster that’s simple to deploy and scale. Whether testing locally or setting up a production-like environment, K3s keeps Kubernetes efficient. 🚀

Docs For More Information
None of this information is anything I came up with myself. All of the information in this post can be learned and figured out at these sources. However, I did verify everything mentioned in this blog to ensure that this is genuinely useful to somebody.

K3s Site

K3D Site
