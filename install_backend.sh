#!/usr/bin/env bash

# Step 1: Download modules
terraform get -update

# Step 2: Initialize your directory/project for use with terraform
# The use of -backend=false here is important: it avoids backend configuration
# on our first call to init since we havent created our backend resources yet
terraform init -backend=false

# Step 3: Create infrastructure plan for just the tf backend resources
# Target only the resources needed for our aws backend for terraform state/locking
terraform plan -var-file=.envs/staging.tfvars -out="./plans/backend.tfplan" -target=module.backend

# Step 4: Apply the infrastructure plan
read -e -p "Apply the Terraform plan? [Y/N] " YN
[[ $YN == "n" || $YN == "N" || $YN == "" ]] && exit 0
terraform apply "./plans/backend.tfplan"

# Step 5: Reinitialize terraform to use your newly provisioned backend
terraform init -reconfigure -force-copy