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
