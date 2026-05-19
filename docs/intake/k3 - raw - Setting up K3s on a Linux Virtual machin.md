Setting up K3s on a Linux Virtual machine
Syed Usman Ahmad
Syed Usman Ahmad

Follow
6 min read
·
Feb 15, 2024

Listen


Share


More

This guide is about how to setup and deploy a K3s Kubernetes cluster which will be running on Linux Virtual machine. Also, if you are interested to learn about using K3s Kubernetes with Helm, then check my follow-up article using this link.

Since this tutorial was too briefly explained with a lot example based scenarios and concepts, so would be best to check out the video.


Setting up K3S on a Linux Virtual Machine
Introduction
K3s is a lightweight Kubernetes distribution designed for resource-constrained environments, such as edge devices, IoT devices, and small clusters. It is a highly optimized version of Kubernetes that aims to reduce the memory and CPU footprint while maintaining full compatibility with the Kubernetes API.

It was originally developed by Rancher(Suse)


Rancher by SUSE
K3s is a now CNCF Sandbox Project.


CNCF Foundation
Advantages
Press enter or click to view image in full size

K3s Kubernetes running on a Linux Virtual machine
K3s offers several advantages over other Kubernetes distributions like Minikube and kinD etc:

Lightweight and Resource-Efficient: K3s is designed to be lightweight and optimized for resource-constrained environments. It has a smaller memory and CPU footprint compared to other Kubernetes distributions, making it suitable for running on edge devices, IoT devices, and small clusters.
Easy Installation and Management: K3s provides a simplified installation process, making it easier to set up and manage Kubernetes clusters. It has minimal dependencies and can be installed with a single binary, reducing the complexity and time required for installation.
High Availability (HA) Support: K3s supports high availability out of the box, allowing you to create highly resilient Kubernetes clusters. It uses built-in features like embedded etcd and automatic leader election to ensure cluster availability even in the event of node failures.
Integrated Add-Ons: K3s includes several integrated add-ons that enhance the functionality of Kubernetes. For example, it includes kube-vip for load balancing and MetalLB for external access to services. These add-ons simplify the configuration and management of common Kubernetes tasks.
Security and Simplicity: K3s prioritizes security and simplicity. It removes or replaces certain components that are not essential for most use cases, reducing the attack surface and making the cluster more secure. Additionally, K3s provides a simplified and opinionated approach to Kubernetes, making it easier for users to adopt and manage.
System Requirements

These are the Minimal system requirements to setup and deploy a single node k3s on any machine.

1. Architecture

k3s is available for the following architectures:

x86_64 (we will be using this one)
armhf
arm64/aarch64
s390x
2. Operating Systems

K3s is expected to work on most modern Linux systems.

3. Hardware requirements

The minimum recommendations are outlined here.


Hardware requirements
4. Networking

The K3s server needs port 6443 to be accessible by all nodes.

For detailed installation, refer to the official docs.

Installation
Pre-requisite
📌 You will need to disable the SWAP Disk space on your machine. That means, on a very basic level we only need a Boot and the Root partition.

You can check my video where I explained on how to create custom partitions while installing Linux.

Step 1 — Setting up the Linux OS
We will be using CentOS as our primary O.S. for this guide. You can use any other Linux distribution of your choice as the steps will be the same.

First, update the system using the command:

dnf -y upgrade
For CentOS 7, just replace the above dnf command with yum.

📌 Reboot the machine if required.

After that, we install the epel-release package to get more up-to-date packages.

dnf -y install epel-release
dnf -y update
Step 2 — Disable Firewall and SELinux
Since we are not deploying our machine in a real production environment, therefore we can simply disable the Linux Firewall and SELinux services to avoid issues that may arrive later.

First, let’s disable the Firewall service.

systemctl stop firewalld
systemctl disable firewalld
Now, let’s disable the SELinux configuration.

Open the following file /etc/selinux/config in your favorite editor:

Set the value for SELINUX

SELINUX=disabled

Save and exit

Step 3 —Setup the hostname
Set a valid hostname inside the file /etc/hosts

Now reboot the machine so that the above changes take effect.

Step 4 — Install the required packages
Install the following packages which are required for the K3s installation.

dnf -y install setroubleshoot-server curl lsof wget tar epel-release vim
Now run the K3s installer script:

curl -sfL https://get.k3s.io | sh
Step 5 — Verifying K3s Service
Let’s review the service in detail:

cat /etc/systemd/system/k3s.service
Also, let’s see the current status of the service:

systemctl status k3s

Your Kubernetes Cluster is up and running !!
Working on K3s
Let’s test out our K3s deployment using the basic commands:

kubectl get pods --all-namespaces
It will show all the Pods.
This means that our K3s cluster is running fine!!

Testing K3s

Let’s deploy a Nginx server on our K3s cluster.

Step 1 — Creating the deployment file
File: nginx.yaml

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
    - protocol: TCP
      port: 8081
      targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
Save and close the nginx.yaml file.

Step 2 — Deploying the file
Deploy the Nginx on your K3s cluster:

kubectl apply -f nginx.yaml
Also, verify that the pods are running:

kubectl get pods
Check the deployment if it is ready:

kubectl get deployments
Step 3 — Accessing the Service
Verify that the load balancer service is running:

kubectl get services nginx
In a web browser navigation bar, type the IP address listed under EXTERNAL_IP from your output and append the port number:8081 to reach the default NGINX welcome page.

Step 4 — Deleting the Deployment
To delete your test Nginx deployment, run the command:

kubectl delete -f nginx.yaml
What’s next? (How to setup Helm)?
Helm with K3s will help you to deploy applications on Kubernetes cluster very quickly and easily using Helm charts. For setting up Helm on K3s requires some more steps. Therefore, please view my follow-up article on how to install and configure Helm that includes step-by-step instructions using this link.

Wrap-up
In this article, you have discovered about K3s which is very lightweight yet powerful Kubernetes cluster. It can be deployed on bare-metal to small ARM machines for IoT devices and also it is extremely easy to install.

Also, learned as how to make K3s working inside a Linux Virtual machine (VMWare, KVM, Virtualbox etc,) with some simple steps and can easily deploy an Nginx server.

With K3s you do not need to worry about ingress/egress as it comes as pre-configured plugins remove the extra overhead of tedious configuration part.

Links to documentation
Here are the links used for this guide:

K3s documenation page (https://k3s.io/)
CentOS (https://www.centos.org/download/)
Nginx (https://www.nginx.com/)
Thank you !!
Thank you very much for reading this article. Please provide your feedback in the comments and appreciate the clap

It takes time to create content and publish it and I try to do it in my free time whenever possible ✍️. I will appreciate your small contribution as it can go a longer way 🙏.
