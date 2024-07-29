#!/bin/bash

# Define variables
PROJECT_ID="tenacious-ring-421314"
ZONE="europe-west10-a"
DB_LOADGEN_VM_NAME="db-load-vm"
METRICS_VM_NAME="metrics-collector-vm"
MACHINE_TYPE="e2-standard-4"
IMAGE_FAMILY="ubuntu-2004-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
DB_STARTUP_SCRIPT="db_startup_script.sh"
METRICS_STARTUP_SCRIPT="metrics_startup_script.sh"

# Create DB/Load Generator VM
gcloud compute instances create $DB_LOADGEN_VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --metadata-from-file startup-script=$DB_STARTUP_SCRIPT \
  --scopes=https://www.googleapis.com/auth/cloud-platform

# Create Metrics Collector VM
gcloud compute instances create $METRICS_VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --metadata-from-file startup-script=$METRICS_STARTUP_SCRIPT \
  --scopes=https://www.googleapis.com/auth/cloud-platform

echo "VMs $DB_LOADGEN_VM_NAME and $METRICS_VM_NAME created."

# Wait for the VMs to be ready
sleep 60

# Get the internal IP of the metrics collector VM
METRICS_VM_INTERNAL_IP=$(gcloud compute instances describe $METRICS_VM_NAME --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')

# Create a firewall rule to allow traffic on port 5432
#gcloud compute firewall-rules create allow-postgres-access \
#    --direction=INGRESS \
#    --priority=1000 \
#    --network=default \
#    --action=ALLOW \
#    --rules=tcp:5432 \
#    --source-ranges=$METRICS_VM_INTERNAL_IP/32

echo "Firewall rule created to allow traffic on port 5432 from $METRICS_VM_INTERNAL_IP"
