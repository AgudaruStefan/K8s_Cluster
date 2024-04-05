#!/bin/bash

# Navigate to the terraform directory
pushd terraform || exit
echo "Applying Terraform commands..."
# Run the Terraform commands
terraform init && terraform apply -auto-approve

# Check if Terraform apply was successful
if [ $? -eq 0 ]; then
    echo "Wait for machines to be ssh ready."
    sleep 25
    echo "Terraform apply completed successfully. Proceeding with Ansible..."
    # Navigate to the ansible directory
    popd
    pushd ansible || exit
    # Run the Ansible playbook
    ansible-playbook k8s_cluster.yaml
else
    echo "Terraform apply failed. Exiting..."
    exit 1
fi

popd

kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s

echo "Installing metallb chart..."
helm install metallb ./helm/metallb-chart
echo "Metallb Installed"

echo "Kube Apply local path storage"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
echo "local path storage applied..."

echo "Patching local-path"
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
echo "Local-path storage Patched"

echo "Installing Redis operator"
helm upgrade redis-operator ot-helm/redis-operator --install
echo "Redis operator installed"

echo "Apply Redis manifest"
kubectl apply -f helm/redis/redis-ia.yaml
echo "Redis manifest applied"

echo "Install harbor chart"
helm install harbor ./helm/harbor
echo "Harbor hart installed"

echo "Install argocd"
helm install argocd ./helm/argocd/argo-cd
echo "argocd installed"

echo "Add jenkins to repo"
helm repo add jenkins https://charts.jenkins.io
helm repo update
echo "Jenkins added to repo"

echo "Install Jenkins"
helm install jenkins jenkins/jenkins -f helm/jenkins/values.yaml
echo "Jenkins installed"

echo "Add ingress to jenkins"
kubectl apply -f helm/jenkins/jenkins-ingress.yaml
echo "Ingress added to jenkins"

sleep 120

echo "Install go-app"
kubectl apply -f helm/argocd/argo-app-go.yaml
echo "Go-app installed"