# Kubernetes Setup

## Access Services

Replace `IP_SERVER` with your VPS or Kubernetes node IP address.

| Service | URL | Port |
|---|---|---|
| Web Application | `http://IP_SERVER/` | `80` |
| Grafana | `http://IP_SERVER:32000` | `32000` |
| phpMyAdmin | `http://IP_SERVER:30090` | `30090` |
| Prometheus | `http://IP_SERVER:32001` | `32001` |

---

# Instalasi Commands
```bash
apt install -y zip unzip curl docker.io nfs-kernel-server
sudo systemctl enable docker
docker --version

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip 103.157.27.242 --advertise-address 103.157.27.242" sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config

kubectl get nodes
kubectl get pods -n kube-system

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
helm install node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring --create-namespace
helm install kube-state-metrics prometheus-community/kube-state-metrics \
  -n monitoring

sudo mkdir -p /ifs/kubernetes
sudo chown -R nobody:nogroup /ifs/kubernetes
sudo chmod 777 /ifs/kubernetes

```

## github runner
buka github project kita lalu ke bagian action>runner

```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.334.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz
echo "048024cd2c848eb6f14d5646d56c13a4def2ae7ee3ad12122bee960c56f3d271  actions-runner-linux-x64-2.334.0.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.334.0.tar.gz
./config.sh --url https://github.com/Ryuushu/ppdb-smp --token <ganti dari github runner>
./run.sh
```

## Run kubernet
```bash
cd /home/kelompok17/project
kubectl apply -k kubernetes/
```


# Restart Kubernetes Commands
workdir atau folder kerja di /home/kelompok17/project
```bash
helm upgrade node-exporter prometheus-community/prometheus-node-exporter \
  -n monitoring

helm upgrade kube-state-metrics prometheus-community/kube-state-metrics \
  -n monitoring
# Step 2: Baru apply kustomize
kubectl apply -k kubernetes/
```

---

# Testting section
## Horizontal pod autoscale(hpa) - Scaling
```bash
kubectl run load-generator \
  -n app \
  --rm -it \
  --image=busybox \
  -- sh

while true; do
  wget -q -O- http://nginx-service/stress > /dev/null
done
```
terminal lain 
```bash
kubectl get hpa -n app -w
```

## load balancing
`http://IP_SERVER/debug/host`

---

# Kubernetes Commands

## Check Services

```bash
kubectl get svc -A
```

Example:

```bash
NAMESPACE     NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)
app           web            NodePort   10.96.10.10     <none>        80:30080/TCP
monitoring    grafana        NodePort   10.96.20.20     <none>        3000:32000/TCP
monitoring    prometheus     NodePort   10.96.30.30     <none>        9090:32001/TCP
database      phpmyadmin     NodePort   10.96.40.40     <none>        80:30090/TCP
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

# Grafana

URL:

```text
http://IP_SERVER:32000
```

Default login:

```text
username: admin
password: admin
```

---

# Prometheus

URL:

```text
http://IP_SERVER:32001
```

---

# phpMyAdmin

URL:

```text
http://IP_SERVER:30090
```

Login using your MariaDB/MySQL credentials.

---

# Monitoring Stack

Components:

- Prometheus → metrics collector
- Grafana → visualization dashboard
- Loki → log aggregation
- Promtail → log shipping

Check monitoring namespace:

```bash
kubectl get all -n monitoring
```

---

# Restart Deployment

```bash
kubectl rollout restart deployment -n app
```

Example:

```bash
kubectl rollout restart deployment laravel -n app
```

---

# Check Logs

```bash
kubectl logs -f deployment/laravel -n app
```

Or:

```bash
kubectl logs -f POD_NAME -n app
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

# Firewall

Open required ports.

Ubuntu UFW example:

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

# Useful Commands

## Show All Resources

```bash
kubectl get all -A
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
