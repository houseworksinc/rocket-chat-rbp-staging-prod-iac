#!/usr/bin/env bash

# Step 1: Download modules
terraform get -update

# Step 2: Create a targeted infrastructure plan for the rocketchat module
terraform plan -var-file=terraform.tfvars -out="./plans/main.tfplan" -target=module.rocketchat

# Step 3: Apply the infrastructure plan
terraform apply "./plans/main.tfplan"
