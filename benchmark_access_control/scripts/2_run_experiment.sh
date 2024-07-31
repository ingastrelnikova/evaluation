#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
VM_NAME="access-ctrl"
ZONE="europe-west10-a"
LOCAL_SCRIPT_PATH="setup_experiment.sh"
REMOTE_SCRIPT_PATH="/home/$VM_USER/app/benchmark_access_control/scripts/setup_experiment.sh"

# SSH into the VM and run the setup script
gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE --command="sudo chmod +x $REMOTE_SCRIPT_PATH && sudo bash $REMOTE_SCRIPT_PATH"

