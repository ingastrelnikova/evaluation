#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
METRICS_VM_NAME="metrics-collector-vm"
ZONE="europe-west10-a"
REMOTE_SCRIPT_PATH="/home/$VM_USER/app/benchmark_reading_metrics/scripts/setup_metrics.sh"

# SSH into the VM and run the setup script
gcloud compute ssh $VM_USER@$METRICS_VM_NAME --zone=$ZONE --command="sudo chmod +x $REMOTE_SCRIPT_PATH && sudo bash $REMOTE_SCRIPT_PATH"
