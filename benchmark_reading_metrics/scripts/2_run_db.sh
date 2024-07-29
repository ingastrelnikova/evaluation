#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
VM_NAME="db-load-vm"  # Update this to the correct VM name
ZONE="europe-west10-a"
REMOTE_SCRIPT_PATH="/home/$VM_USER/app/benchmark_writing_db/scripts/setup_db.sh"

# SSH into the VM and run the setup script
gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE --command="sudo chmod +x $REMOTE_SCRIPT_PATH && sudo bash $REMOTE_SCRIPT_PATH"


