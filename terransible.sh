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

echo "======================================="
echo "Ansible playbook successfully finished."
echo "======================================="

popd

wait_for_pod_ready() {
    echo "=== Waiting for Metallb pod to be ready ==="
    kubectl wait --namespace metallb-system \
      --for=condition=ready pod \
      --selector=app=metallb \
      --timeout=90s
}

install_metallb() {
    echo "=== Installing Metallb chart ==="
    helm install metallb ./helm/metallb-chart
    echo "Metallb Installed"
}

apply_local_path_storage() {
    echo "=== Applying local path storage ==="
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
    echo "Local path storage applied"

    echo "=== Patching local-path ==="
    kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    echo "Local-path storage Patched"
}

install_redis_operator() {
    echo "=== Installing Redis operator ==="
    helm upgrade redis-operator ot-helm/redis-operator --install
    echo "Redis operator installed"

    echo "=== Applying Redis manifest ==="
    kubectl apply -f helm/redis/redis-ia.yaml
    echo "Redis manifest applied"
}

install_harbor() {
    echo "=== Installing harbor chart ==="
    helm repo add harbor https://helm.goharbor.io
    helm install harbor harbor/harbor -f helm/harbor/values.yaml
    echo "Harbor chart installed"
}

install_argocd() {
    echo "=== Installing argocd ==="
    helm repo add argo https://argoproj.github.io/argo-helm
    helm install argocd argo/argo-cd -f helm/argocd/values.yaml
    echo "argocd installed"
}

add_jenkins_to_repo() {
    echo "=== Adding Jenkins to repo ==="
    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    echo "Jenkins added to repo"
}

install_jenkins() {
    echo "=== Installing Jenkins ==="
    helm install jenkins jenkins/jenkins -f helm/jenkins/values.yaml
    echo "Jenkins installed"

    echo "=== Adding ingress to Jenkins ==="
    kubectl apply -f helm/jenkins/jenkins-ingress.yaml
    echo "Ingress added to Jenkins"
}

install_go_app() {
    echo "=== Installing go-app ==="
    kubectl apply -f helm/argocd/argo-app-go.yaml
    echo "Go-app installed"
}

wait_for_pod_ready
install_metallb
apply_local_path_storage
install_redis_operator
install_harbor
install_argocd
add_jenkins_to_repo
install_jenkins
sleep 120
install_go_app

echo "=== All operations completed ==="