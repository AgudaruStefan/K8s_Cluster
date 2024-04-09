# Useful information

## How to get the default admin password of argocd

Password:

```bash
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Default username will be "admin".

## Changes to yaml file

Enable ingress:

```yaml
  ingress:
    enabled: true
```

Add ingress class, hostname, path and pathType:

```yaml
    ingressClassName: "nginx"
    hostname: "argo.nginx-app.info"
    path: /
    pathType: Prefix
```

Disable tls:

```yaml
    tls: false
```
