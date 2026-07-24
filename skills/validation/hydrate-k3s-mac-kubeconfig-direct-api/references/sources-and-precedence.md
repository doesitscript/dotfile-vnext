# Sources And Precedence

1. Live `kubectl get nodes` with the per-cluster kubeconfig / current context
2. `server:` field inside `~/.kube/hom-lab-ctl-k3s-*.yaml`
3. Mac route reachability to guest `:6443`
4. Inventory `connection_mode: direct` on `mac-dev`
5. Role tasks in `roles/k3s_mac_client/`
