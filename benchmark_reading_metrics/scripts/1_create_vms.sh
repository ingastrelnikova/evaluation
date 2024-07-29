#!/bin/bash

# Define variables
DB_LOADGEN_VM_NAME="db-load-vm"
METRICS_VM_NAME="metrics-collector-vm"
ZONE="europe-west10-a"
MACHINE_TYPE="e2-standard-4"
IMAGE_FAMILY="ubuntu-2004-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
VM_USER="ingastrelnikova28"
REMOTE_CODE_DIR="/home/$VM_USER/app/benchmark_reading_metrics/data"
REMOTE_METRICS_CODE_DIR="/home/$VM_USER/app/benchmark_reading_metrics/metrics"

# Create VMs
gcloud compute instances create $DB_LOADGEN_VM_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --tags=http-server,https-server

gcloud compute instances create $METRICS_VM_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --tags=http-server,https-server

# Wait for the VMs to be ready
sleep 60

# Get the internal IP of the metrics collector VM
METRICS_VM_INTERNAL_IP=$(gcloud compute instances describe metrics-collector-vm --zone=europe-west10-a --format='get(networkInterfaces[0].networkIP)')

# Create a firewall rule to allow traffic on port 5432
gcloud compute firewall-rules create allow-postgres-access \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:5432 \
    --source-ranges=$METRICS_VM_INTERNAL_IP/32


# Function to install Docker and set up environment
setup_docker() {
    VM_NAME=$1
    gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE --command="sudo apt-get update && sudo apt-get install -y docker.io && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker $USER"
}

# Setup Docker on both VMs
setup_docker $DB_LOADGEN_VM_NAME
setup_docker $METRICS_VM_NAME

# Clone GitHub repository
gcloud compute ssh $VM_USER@$DB_LOADGEN_VM_NAME --zone=$ZONE --command="git clone https://github.com/ingastrelnikova/evaluation.git /home/ingastrelnikova28/app"

# Run Docker Compose on the DB/Load Generator VM
gcloud compute ssh $VM_USER@$DB_LOADGEN_VM_NAME --zone=$ZONE --command="cd $REMOTE_CODE_DIR && docker-compose up -d"

# Get external IP of the DB/Load Generator VM
DB_LOADGEN_VM_IP=$(gcloud compute instances describe $DB_LOADGEN_VM_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Update environment variable for the Metrics Collector's docker-compose.yml
gcloud compute ssh $VM_USER@$METRICS_VM_NAME --zone=$ZONE --command="git clone $GITHUB_REPO_METRICS $REMOTE_METRICS_CODE_DIR && sed -i.bak 's/DB_HOST:.*/DB_HOST: $DB_LOADGEN_VM_IP/' $REMOTE_METRICS_CODE_DIR/docker-compose.yml"

# Run Docker Compose on the Metrics Collector VM
gcloud compute ssh $VM_USER@$METRICS_VM_NAME --zone=$ZONE --command="cd $REMOTE_METRICS_CODE_DIR && docker-compose up -d"
