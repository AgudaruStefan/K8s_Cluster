#!/bin/bash

# Navigate to the terraform directory
cd terraform || exit
echo "Destroying Terraform resources..."
# Run Terraform destroy
terraform destroy -auto-approve