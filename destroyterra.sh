#!/bin/bash

# Navigate to the terraform directory
pushd terraform || exit
echo "Destroying Terraform resources..."
# Run Terraform destroy
terraform destroy -auto-approve