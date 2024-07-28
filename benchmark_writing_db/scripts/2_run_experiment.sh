#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
VM_NAME="db-vm"
ZONE="europe-west10-a"
LOCAL_SCRIPT_PATH="setup_experiment.sh"
REMOTE_SCRIPT_PATH="/home/$VM_USER/app/benchmark_writing_db/scripts/setup_experiment.sh"

# Upload the setup script to the VM
#gcloud compute scp $LOCAL_SCRIPT_PATH $VM_USER@$VM_NAME:$REMOTE_SCRIPT_PATH --zone=$ZONE

# SSH into the VM and run the setup script
gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE --command="sudo chmod +x $REMOTE_SCRIPT_PATH && sudo bash $REMOTE_SCRIPT_PATH"
