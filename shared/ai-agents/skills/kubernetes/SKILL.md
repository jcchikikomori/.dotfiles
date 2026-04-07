---
name: kubernetes
description: Kubernetes best practices, translating Docker concepts to K8s, writing manifests (Deployments, Services), and using kubectl.
---

# Kubernetes (K8s) Developer Skill

**Roadmap Alignment:** [roadmap.sh/kubernetes](https://roadmap.sh/kubernetes)
**Reference:** [Kubernetes Official Docs](https://kubernetes.io/docs/home/) | [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Context for Docker Users
Since you are familiar with Docker, here is how concepts translate to Kubernetes:
- **Container** → **Pod** (A pod is the smallest deployable unit and usually contains one container, sometimes more).
- **`docker-compose.yml`** → **Manifests** (Usually split into multiple YAML files like `Deployment`, `Service`, `ConfigMap`).
- **Docker Volumes** → **PersistentVolume (PV) / PersistentVolumeClaim (PVC)**.
- **Port Mapping (`-p 8080:80`)** → **Service** (Exposes your pods to the network).
- **Environment Variables (`.env`)** → **ConfigMap** (for non-sensitive data) and **Secret** (for sensitive data).

## Core Standards & Best Practices

### 1. Declarative Configuration
- Always use YAML manifests and apply them via `kubectl apply -f file.yaml`. 
- **Avoid Imperative Commands:** Do not use `kubectl create` or `kubectl run` for creating production resources. Keep everything version-controlled in Git (GitOps).

### 2. Workload Management
- **Never create naked Pods.** Always use a higher-level abstraction:
  - **Deployment:** For stateless web servers, APIs, etc.
  - **StatefulSet:** For databases or stateful applications requiring stable persistent storage.
  - **DaemonSet:** For background agents running on every node (e.g., logging/monitoring).
  - **Job / CronJob:** For one-off or scheduled batch tasks.

### 3. Resilience and Reliability
- **Probes:** Always configure `livenessProbe` (restarts the pod if it crashes) and `readinessProbe` (stops sending traffic to the pod if it's busy/starting up).
- **Resource Limits:** Always define CPU and Memory `requests` (what it needs to schedule) and `limits` (maximum it can use). Without these, a memory leak in one pod can crash the entire node.
- **Replicas:** Run at least 2 replicas for high availability, paired with a PodAntiAffinity rule to ensure they don't land on the same physical server.

### 4. Networking & Security
- **Services:** Use `ClusterIP` for internal communication. Use `Ingress` (with a controller like NGINX) to expose HTTP/HTTPS traffic to the outside world, rather than `NodePort` or `LoadBalancer`.
- **Namespaces:** Use Namespaces to logically separate environments (e.g., `dev`, `staging`, `prod`) or different teams within the same cluster.
- **RBAC:** Apply the principle of least privilege using Role-Based Access Control. Don't give pods administrative access to the K8s API unless absolutely necessary.

## Common `kubectl` Commands for Docker Users
| Docker Command | Kubernetes Equivalent | Purpose |
|----------------|-----------------------|---------|
| `docker ps` | `kubectl get pods` | List running containers/pods |
| `docker logs -f <id>` | `kubectl logs -f <pod-name>` | Tail logs |
| `docker exec -it <id> sh` | `kubectl exec -it <pod-name> -- sh` | Open a shell inside |
| `docker stop <id>` | `kubectl delete pod <pod-name>` | K8s will automatically restart it if managed by a Deployment |

### Output Format
When generating Kubernetes YAMLs, ensure you use the `apps/v1` (or current stable) API versions, include basic labels (`app: [name]`), and explain *why* certain blocks (like probes or limits) were included to help build intuition for K8s.