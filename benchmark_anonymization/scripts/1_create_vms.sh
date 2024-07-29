#!/bin/bash

# Define variables
PROJECT_ID="tenacious-ring-421314"
ZONE="europe-west10-a"
ANON_SERVICE_VM_NAME="anonymization-service-vm"
DB="anon-db"
MACHINE_TYPE="e2-standard-4"
IMAGE_FAMILY="ubuntu-2004-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
DB_STARTUP_SCRIPT="db_startup_script.sh"
ANON_STARTUP_SCRIPT="anon_startup_script.sh"



# Create DB VM
gcloud compute instances create $ANON_SERVICE_VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --metadata-from-file startup-script=$ANON_STARTUP_SCRIPT \
  --scopes=https://www.googleapis.com/auth/cloud-platform

# Create Anonymization Service VM
gcloud compute instances create $DB \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --metadata-from-file startup-script=$DB_STARTUP_SCRIPT \
  --scopes=https://www.googleapis.com/auth/cloud-platform

echo "VMs $DB and $ANON_SERVICE_VM_NAME created."

# Wait for the VMs to be ready
sleep 60


# Create a firewall rule to allow traffic on port 5432
#gcloud compute firewall-rules create allow-postgres-access \
#    --direction=INGRESS \
#    --priority=1000 \
#    --network=default \
#    --action=ALLOW \
#    --rules=tcp:5432 \
#    --source-ranges=$METRICS_VM_INTERNAL_IP/32

#echo "Firewall rule created to allow traffic on port 5432 from $METRICS_VM_INTERNAL_IP"
