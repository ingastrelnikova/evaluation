#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
VM_NAME="db-vm"
ZONE="europe-west10-a"
LOCAL_LOG_DIR="./logs"           # The directory on your local machine to save the logs
REMOTE_LOG_FILE="/home/$VM_USER/app/benchmark/data/write_log.csv"
REMOTE_COMPLETION_FILE="/home/$VM_USER/experiment_complete.txt"

# Create the local log directory if it doesn't exist
mkdir -p $LOCAL_LOG_DIR

# Check if the experiment is complete
gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE -- "test -f $REMOTE_COMPLETION_FILE && echo 'Experiment complete' || echo 'Experiment not complete'"

# Download the log file if the experiment is complete
if gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE -- "test -f $REMOTE_COMPLETION_FILE"; then
    scp $VM_USER@$VM_NAME:$REMOTE_LOG_FILE $LOCAL_LOG_DIR
    echo "Log file downloaded to $LOCAL_LOG_DIR"
else
    echo "Experiment not complete yet. Please wait and try again."
fi
