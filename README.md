# Inception‑of‑Things — K3s/K3d + Argo CD GitOps Lab

From K3s on Vagrant (controller/worker, Ingress with host‑based routing) to K3d with Argo CD GitOps auto‑deploy (v1→v2), fully scripted and reproducible.

## Structure
```
/p1   # Vagrant + K3s: controller/worker, SSH no‑password
/p2   # K3s (server) + 3 apps + Ingress host routing, replicas, default fallback
/p3   # K3d + Argo CD, namespaces (argocd, dev), GitOps (v1/v2)
```

## Part 1 — K3s + Vagrant
- 2 VMs via Vagrant (512–1024 MB RAM, 1 vCPU)
- Hostnames: <login>S (server), <login>SW (worker); IPs: 192.168.56.110/111 on eth1
- K3s controller/agent; kubectl installed; SSH key‑based login

## Part 2 — K3s + 3 Apps
- Single VM K3s (server)
- 3 web apps exposed via Ingress with rules:
  - HOST: app1.com → app1
  - HOST: app2.com → app2 (3 replicas)
  - default backend → app3
- Show Ingress to evaluators; verify replicas and default routing

## Part 3 — K3d + Argo CD (GitOps)
- K3d cluster (Docker)
- Namespaces: argocd, dev
- Argo CD installed in argocd; Application targets dev
- App image pinned by tag (v1 → v2); update via Git push
- Validate sync in Argo UI and curl response change

## Scripts
- scripts/bootstrap.sh   # install Docker, K3d, kubectl, Argo CD CLI
- scripts/k3s_install.sh # K3s install (p1/p2)
- scripts/hosts.sh       # add /etc/hosts entries for app1.com/app2.com
- scripts/demo_v2.sh     # sed v1→v2 in manifests and push

## Commands (examples)
```
# K3d + Argo CD quickstart (p3)
./scripts/bootstrap.sh
k3d cluster create iot --agents 1
kubectl create ns argocd && kubectl apply -n argocd -f confs/argocd/install.yaml
kubectl apply -n argocd -f confs/argocd/ingress.yaml
kubectl create ns dev
kubectl apply -n dev -f confs/app/deployment.yaml
kubectl apply -n dev -f confs/app/service.yaml
kubectl apply -n dev -f confs/app/ingress.yaml
# Argo CD Application (points to your public GitHub repo)
kubectl apply -f confs/argocd/application.yaml
```

## Validation
- kubectl get ns (argocd, dev present)
- kubectl get pods -n dev (app running)
- curl http://localhost:8888/ → {"status":"ok","message":"v1"}
- Update to v2 in Git, wait for sync, curl shows v2

## Notes (Compliance with 42 IoT)
- All work in VMs/containers per spec
- Public GitHub repo required for p3
- Show Ingress to evaluators
- Bonus: local GitLab in gitlab namespace with Helm (optional)

## What to Demo
- Host‑based routing working (p2)
- Scaling for app2 replicas
- Argo CD sync v1→v2 from Git change (p3)
