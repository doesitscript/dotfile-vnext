# Sources And Precedence

1. Playbook tunnel probe/health tasks and `kubectl get nodes`
2. Local listeners on tunnel ports
3. Per-cluster kubeconfig `server: https://127.0.0.1:<port>`
4. Inventory `connection_mode: ssh_tunnel`
5. Jump-host SSH connectivity
