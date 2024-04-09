# Useful information

## Get default Jenkins admin password

Password:

```bash
kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo\n
```

Default username will be "admin".
