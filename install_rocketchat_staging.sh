#!/usr/bin/env bash

# Step 1: Download modules
terraform get -update

# Step 2: Create a targeted infrastructure plan for the rocketchat module
terraform plan -var-file=.envs/staging.tfvars -out="./plans/staging.tfplan" -target=module.rocketchat

# Step 3: Apply the infrastructure plan
read -e -p "Apply the Terraform plan? [Y/N] " YN
[[ $YN == "n" || $YN == "N" || $YN == "" ]] && exit 0
terraform apply "./plans/staging.tfplan"
