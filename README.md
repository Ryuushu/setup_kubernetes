# Kubernetes Deployment Setup

Dokumentasi deployment Kubernetes menggunakan K3s, Docker, NFS Storage, Prometheus, Grafana, Loki, Promtail, dan GitHub Actions Runner.

---

# Table of Contents

- [Architecture](#architecture)
- [Access Services](#access-services)
- [Installation](#installation)
- [NFS Storage Setup](#nfs-storage-setup)
- [GitHub Runner Setup](#github-runner-setup)
- [Deploy Application](#deploy-application)
- [Monitoring Stack](#monitoring-stack-grafana--prometheus--loki-on-k3s)
- [Restart Kubernetes](#restart-kubernetes)
- [Testing](#testing)
- [Useful Kubernetes Commands](#useful-kubernetes-commands)
- [Troubleshooting](#troubleshooting)
- [Ports](#ports)

---

# Architecture

Komponen yang digunakan pada environment Kubernetes ini:

- **K3s** → Distribusi Kubernetes ringan
- **Docker** → Container runtime
- **NFS Server** → Shared persistent storage
- **Prometheus** → Pengumpul metrics
- **Grafana** → Visualisasi metrics
- **Loki** → Log aggregation
- **Promtail** → Pengirim log ke Loki
- **GitHub Actions Runner** → Otomasi CI/CD

---

# Access Services

Ganti `IP_SERVER` dengan IP VPS atau node Kubernetes Anda.

| Service | URL | Port |
|---|---|---|
| Web Application | `http://IP_SERVER/` | `80` |
| Grafana | `http://IP_SERVER:32000` | `32000` |
| phpMyAdmin | `http://IP_SERVER:30090` | `30090` |
| Prometheus | `http://IP_SERVER:32001` | `32001` |

---

# Installation

## Install Dependencies

Install package yang dibutuhkan:

```bash
apt install -y zip unzip curl docker.io nfs-kernel-server
```

Aktifkan Docker:

```bash
systemctl enable docker
```

Cek versi Docker:

```bash
docker --version
```

---

## Install K3s

Install K3s menggunakan IP server:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 103.157.27.242 --advertise-address 103.157.27.242" sh -
```

Set environment Kubernetes:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Buat konfigurasi kube:

```bash
mkdir -p /root/.kube

cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
```

Verifikasi node Kubernetes:

```bash
kubectl get nodes
```

Cek pod bawaan K3s:

```bash
kubectl get pods -n kube-system
```

---

## Install Helm

Install Helm:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Tambahkan repository Prometheus:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update repository Helm:

```bash
helm repo update
```

---

## Install Monitoring Stack

Install Node Exporter:

```bash
helm install node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring \
  --create-namespace
```

Install kube-state-metrics:

```bash
helm install kube-state-metrics prometheus-community/kube-state-metrics \
  -n monitoring
```

---

# NFS Storage Setup

## Create NFS Directory

Buat direktori storage untuk Kubernetes:

```bash
mkdir -p /ifs/kubernetes
```

Atur ownership:

```bash
chown -R nobody:nogroup /ifs/kubernetes
```

Atur permission:

```bash
chmod 777 /ifs/kubernetes
```

---

## Configure NFS Export

Edit file:

```text
/etc/exports
```

Tambahkan konfigurasi berikut:

```bash
/ifs/kubernetes *(rw,sync,no_subtree_check,no_root_squash)
```

Apply konfigurasi NFS:

```bash
exportfs -ra
```

Restart service NFS:

```bash
systemctl restart nfs-kernel-server
```

---

# NFS Client Provisioner

Pastikan IP server pada file deployment sudah sesuai dengan IP VPS Kubernetes.

## deployment.yaml

Contoh konfigurasi:

```yaml
nfs:
  server: 103.157.27.242
  path: /ifs/kubernetes
```

---

# GitHub Runner Setup

Buka repository GitHub:

```text
Repository → Actions → Runners
```

---

## Install GitHub Actions Runner

Buat direktori runner:

```bash
mkdir actions-runner && cd actions-runner
```

Download runner:

```bash
curl -o actions-runner-linux-x64-2.334.0.tar.gz -L \
https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz
```

Verifikasi checksum:

```bash
echo "048024cd2c848eb6f14d5646d56c13a4def2ae7ee3ad12122bee960c56f3d271  actions-runner-linux-x64-2.334.0.tar.gz" | shasum -a 256 -c
```

Extract file:

```bash
tar xzf ./actions-runner-linux-x64-2.334.0.tar.gz
```

Konfigurasi runner:

```bash
./config.sh \
  --url https://github.com/Ryuushu/ppdb-smp \
  --token <GITHUB_RUNNER_TOKEN>
```

Jalankan runner:

```bash
./run.sh
```

---

# Deploy Application

Masuk ke directory project:

```bash
cd /home/kelompok17/project/setup_kubernates
```

Deploy manifest Kubernetes:

```bash
kubectl apply -k kubernetes/
```

Masuk ke pod Laravel lalu jalankan migrate dan seeder:

```bash
php artisan migrate --seed
```

---

---

# Monitoring Stack (Grafana + Prometheus + Loki) on K3s

## Overview

Repository ini menggunakan monitoring stack Kubernetes berbasis:

- Grafana
- Prometheus
- Loki

---

# Login to Grafana

Buka browser:

```text
http://<IP_SERVER>:32000
```

---

# Add Prometheus Datasource

Biasanya datasource Prometheus otomatis dibuat oleh kube-prometheus-stack.

Cek datasource:

1. Buka Grafana
2. Masuk ke:

```text
Connections → Data Sources
```

3. Pastikan datasource Prometheus tersedia.

Default URL:

```text
http://prometheus.monitoring.svc.cluster.local:9090
```

---

# Manual Add Prometheus Datasource

Jika datasource belum tersedia:

## Open Datasource Menu

```text
Connections → Data Sources → Add data source
```

Pilih:

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

Klik:

```text
Save & Test
```

Hasil yang diharapkan:

```text
Data source is working
```

---

# Add Loki Datasource

## Add Data Source

Masuk ke:

```text
Connections → Data Sources → Add data source
```

Pilih:

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

Klik:

```text
Save & Test
```

Hasil yang diharapkan:

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

Dashboard populer Kubernetes:

| Dashboard | ID |
|---|---|
| Kubernetes Cluster Monitoring | 315 |
| Node Exporter Full | 1860 |
| Kubernetes Pod Monitoring | 6417 |

Contoh:

```text
1860
```

---

## Select Datasource

Pilih datasource:

```text
Prometheus
```

Klik:

```text
Import
```

---

# Explore Metrics

Masuk ke menu:

```text
Explore
```

Pilih datasource:

```text
Prometheus
```

Contoh query:

```promql
up
```

---

# Import Loki Dashboard JSON

Setelah datasource Loki berhasil ditambahkan:

Buka sidebar Grafana:

```text
Dashboards → New → Import
```

---

# Upload Dashboard JSON

Klik:

```text
Upload dashboard JSON file
```

Pilih file:

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

## Restart K3s dan Monitoring Components

Restart service K3s:

```bash
systemctl restart k3s
```

Upgrade Node Exporter:

```bash
helm upgrade node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring
```

Upgrade kube-state-metrics:

```bash
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

## Horizontal Pod Autoscaler (HPA)

### Generate Load

Jalankan container busybox:

```bash
kubectl run load-generator \
  -n app \
  --rm -it \
  --image=busybox \
  -- sh
```

Di dalam container:

```bash
while true; do
  wget -q -O- http://nginx-service/stress > /dev/null
done
```

---

## Monitor HPA

Buka terminal lain:

```bash
kubectl get hpa -n app -w
```

---

## Load Balancing

Akses endpoint berikut:

```text
http://IP_SERVER/debug/host
```

Refresh halaman beberapa kali untuk memastikan request terdistribusi ke beberapa pod.

---

## phpMyAdmin

URL:

```text
http://IP_SERVER:30090
```

Login menggunakan credential MariaDB/MySQL.

---

## Check Monitoring Namespace

```bash
kubectl get all -n monitoring
```

---

# Useful Kubernetes Commands

Bagian berikut berisi command Kubernetes yang sering digunakan untuk monitoring, debugging, dan management cluster.

---

## Show All Resources

Menampilkan seluruh resource di semua namespace:

```bash
kubectl get all -A
```

---

## Check Services

Menampilkan daftar service:

```bash
kubectl get svc -A
```

---

## Check Pods

Menampilkan seluruh pod:

```bash
kubectl get pod -A
```

---

## Check Ingress

Menampilkan ingress:

```bash
kubectl get ingress -A
```

---

## Restart Deployment

Restart deployment pada namespace tertentu:

```bash
kubectl rollout restart deployment -n app
```

Contoh restart deployment Laravel:

```bash
kubectl rollout restart deployment laravel -n app
```

---

## View Deployment Logs

Melihat log deployment secara realtime:

```bash
kubectl logs -f deployment/laravel -n app
```

---

## View Pod Logs

Melihat log pod:

```bash
kubectl logs -f POD_NAME -n app
```

---

## Enter Container

Masuk ke shell container:

```bash
kubectl exec -it POD_NAME -n app -- sh
```

---

## Delete Pod

Menghapus pod:

```bash
kubectl delete pod POD_NAME -n app
```

---

## Apply Manifest

Apply manifest Kubernetes:

```bash
kubectl apply -f .
```

---

## Delete Manifest

Menghapus manifest Kubernetes:

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

Buka port yang diperlukan:

```bash
ufw allow 80/tcp

ufw allow 32000/tcp

ufw allow 32001/tcp

ufw allow 30090/tcp
```

---

# Troubleshooting

## Pod CrashLoopBackOff

Cek detail pod:

```bash
kubectl describe pod POD_NAME -n app
```

Lihat log pod:

```bash
kubectl logs POD_NAME -n app
```

---

## Service Cannot Be Accessed

Cek service Kubernetes:

```bash
kubectl get svc -A
```

Cek firewall:

```bash
ufw status
```

---

## Ingress Not Working

Cek ingress controller:

```bash
kubectl get pods -n ingress-nginx
```

---

# Maintainer

Project ini dibuat untuk deployment Kubernetes, monitoring, autoscaling, dan otomasi CI/CD menggunakan GitHub Actions Runner.
