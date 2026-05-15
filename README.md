# Kubernetes Deployment Setup

Deployment documentation for Kubernetes environment using K3s, Docker, NFS Storage, Prometheus, Grafana, Loki, Promtail, and GitHub Actions Runner.

---

# Table of Contents

- [Architecture](#architecture)
- [Access Services](#access-services)
- [Installation](#installation)
- [NFS Storage Setup](#nfs-storage-setup)
- [GitHub Runner Setup](#github-runner-setup)
- [Deploy Application](#deploy-application)
- [Restart Kubernetes](#restart-kubernetes)
- [Testing](#testing)
- [Monitoring](#monitoring)
- [Useful Kubernetes Commands](#useful-kubernetes-commands)
- [Troubleshooting](#troubleshooting)
- [Ports](#ports)

---

# Architecture

Components used in this Kubernetes environment:

- **K3s** → Lightweight Kubernetes distribution
- **Docker** → Container runtime
- **NFS Server** → Persistent shared storage
- **Prometheus** → Metrics collector
- **Grafana** → Metrics visualization
- **Loki** → Log aggregation
- **Promtail** → Log shipping
- **GitHub Actions Runner** → CI/CD automation

---

# Access Services

Replace `IP_SERVER` with your VPS or Kubernetes node IP address.

| Service | URL | Port |
|---|---|---|
| Web Application | `http://IP_SERVER/` | `80` |
| Grafana | `http://IP_SERVER:32000` | `32000` |
| phpMyAdmin | `http://IP_SERVER:30090` | `30090` |
| Prometheus | `http://IP_SERVER:32001` | `32001` |

---

# Installation

## Install Dependencies

```bash
apt install -y zip unzip curl docker.io nfs-kernel-server

systemctl enable docker

docker --version
```

---

## Install K3s

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 103.157.27.242 --advertise-address 103.157.27.242" sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

mkdir -p /root/.kube

cp /etc/rancher/k3s/k3s.yaml /root/.kube/config

kubectl get nodes

kubectl get pods -n kube-system
```

---

## Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

---

## Install Monitoring Stack

```bash
helm install node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring \
  --create-namespace

helm install kube-state-metrics prometheus-community/kube-state-metrics \
  -n monitoring
```

---

# NFS Storage Setup

## Create NFS Directory

```bash
mkdir -p /ifs/kubernetes

chown -R nobody:nogroup /ifs/kubernetes

chmod 777 /ifs/kubernetes
```

---

## Configure NFS Export

Edit `/etc/exports`

```bash
/ifs/kubernetes *(rw,sync,no_subtree_check,no_root_squash)
```

Apply configuration:

```bash
exportfs -ra

systemctl restart nfs-kernel-server
```

---

# NFS Client Provisioner

ubah ip ke ip server
## deployment.yaml


---

# GitHub Runner Setup

Open your GitHub repository:

```text
Repository → Actions → Runners
```

---

## Install GitHub Actions Runner

```bash
mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.334.0.tar.gz -L \
https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz

echo "048024cd2c848eb6f14d5646d56c13a4def2ae7ee3ad12122bee960c56f3d271  actions-runner-linux-x64-2.334.0.tar.gz" | shasum -a 256 -c

tar xzf ./actions-runner-linux-x64-2.334.0.tar.gz

./config.sh \
  --url https://github.com/Ryuushu/ppdb-smp \
  --token <GITHUB_RUNNER_TOKEN>

./run.sh
```

---

# Deploy Application

```bash
cd /home/kelompok17/project/setup_kubernates

kubectl apply -k kubernetes/
```
masuk ke pod lalu lakukan php artisan migrate --seed
---

---
# Monitoring Stack (Grafana + Prometheus + Loki) on K3s

## Overview

This repository contains a monitoring stack deployment for Kubernetes/K3s using:

- Grafana
- Prometheus
- Loki

---

# Login to Grafana

Open browser:

```text
http://<IP SERVER>:32000
```
---

# Add Prometheus Datasource

Usually auto-configured by kube-prometheus-stack.

Check datasource:

1. Open Grafana
2. Go to:

```text
Connections → Data Sources
```

3. Verify Prometheus exists

Default URL:

```text
http://prometheus.monitoring.svc.cluster.local:9090
```

---

# Manual Add Prometheus Datasource

If datasource does not exist:

## Open Datasource Menu

```text
Connections → Data Sources → Add data source
```

Select:

```text
Prometheus
```

---

## Configure URL

```text
http://prometheus.monitoring.svc.cluster.local:9090
```

---

## Save and Test

Click:

```text
Save & Test
```

Expected result:

```text
Data source is working
```

---

# Add Loki Datasource

## Add Data Source

Go to:

```text
Connections → Data Sources → Add data source
```

Select:

```text
Loki
```

---

## Configure Loki URL

```text
http://loki.monitoring.svc.cluster.local:3100
```

---

## Save and Test

Click:

```text
Save & Test
```

Expected result:

```text
Data source connected successfully
```

---

# Import Kubernetes Dashboard

## Open Dashboard Import

```text
Dashboards → Import
```

---

## Import Dashboard ID

Popular Kubernetes dashboards:

| Dashboard | ID |
|---|---|
| Kubernetes Cluster Monitoring | 315 |
| Node Exporter Full | 1860 |
| Kubernetes Pod Monitoring | 6417 |

Example:

```text
1860
```

---

## Select Datasource

Choose:

```text
Prometheus
```

Click:

```text
Import
```

---

# Explore Metrics

Go to:

```text
Explore
```

Select datasource:

```text
Prometheus
```

Example query:

```promql
up
```

---

# Import Loki Dashboard JSON

After Loki datasource is working:

Open Grafana sidebar:

```text
Dashboards → New → Import
```

---

# Upload JSON Dashboard

Click:

```text
Upload dashboard JSON file
```

Select file:

```text
dashboard loki.json
```

---



---

# Restart Kubernetes

Working directory:

```text
/home/kelompok17/project
```

---

## Restart K3s and Monitoring Components

```bash
systemctl restart k3s

helm upgrade node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring

helm upgrade kube-state-metrics prometheus-community/kube-state-metrics \
  -n monitoring
```

---

## Re-Apply Kubernetes Manifest

```bash
kubectl apply -k kubernetes/
```

---

# Testing

# Horizontal Pod Autoscaler (HPA)

## Generate Load

```bash
kubectl run load-generator \
  -n app \
  --rm -it \
  --image=busybox \
  -- sh
```

Inside the container:

```bash
while true; do
  wget -q -O- http://nginx-service/stress > /dev/null
done
```

---

## Monitor HPA

Open another terminal:

```bash
kubectl get hpa -n app -w
```

---

# Load Balancing

```text
http://IP_SERVER/debug/host
```

Refresh the page multiple times to verify request distribution between pods.

---

---
## phpMyAdmin

URL:

```text
http://IP_SERVER:30090
```

Login using your MariaDB/MySQL credentials.

---

## Check Monitoring Namespace

```bash
kubectl get all -n monitoring
```

---

# Useful Kubernetes Commands

## Show All Resources

```bash
kubectl get all -A
```

---

## Check Services

```bash
kubectl get svc -A
```

---

## Check Pods

```bash
kubectl get pod -A
```

---

## Check Ingress

```bash
kubectl get ingress -A
```

---

## Restart Deployment

```bash
kubectl rollout restart deployment -n app
```

Example:

```bash
kubectl rollout restart deployment laravel -n app
```

---

## View Deployment Logs

```bash
kubectl logs -f deployment/laravel -n app
```

---

## View Pod Logs

```bash
kubectl logs -f POD_NAME -n app
```

---

## Enter Container

```bash
kubectl exec -it POD_NAME -n app -- sh
```

---

## Delete Pod

```bash
kubectl delete pod POD_NAME -n app
```

---

## Apply Manifest

```bash
kubectl apply -f .
```

---

## Delete Manifest

```bash
kubectl delete -f .
```

---

# Ports

| Port | Description |
|---|---|
| 80 | Web Application |
| 32000 | Grafana |
| 32001 | Prometheus |
| 30090 | phpMyAdmin |

---

# Firewall Configuration

## UFW Example

```bash
ufw allow 80/tcp

ufw allow 32000/tcp

ufw allow 32001/tcp

ufw allow 30090/tcp
```

---

# Troubleshooting

## Pod CrashLoopBackOff

```bash
kubectl describe pod POD_NAME -n app

kubectl logs POD_NAME -n app
```

---

## Service Cannot Be Accessed

Check services:

```bash
kubectl get svc -A
```

Check firewall:

```bash
ufw status
```

---

## Ingress Not Working

```bash
kubectl get pods -n ingress-nginx
```

---

# Maintainer

Project maintained for Kubernetes deployment, monitoring, autoscaling, and CI/CD automation using GitHub Actions Runner.
