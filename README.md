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
