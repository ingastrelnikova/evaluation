#!/bin/bash

PROJECT_ID="tenacious-ring-421314"
ZONE="europe-west10-a"
VM_NAME="db-vm"
MACHINE_TYPE="e2-standard-4"
IMAGE_FAMILY="ubuntu-2004-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
STARTUP_SCRIPT="startup_script.sh"

# create VM instance
gcloud compute instances create $VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --metadata-from-file startup-script=$STARTUP_SCRIPT \
  --scopes=https://www.googleapis.com/auth/cloud-platform

echo "VM $VM_NAME created."
