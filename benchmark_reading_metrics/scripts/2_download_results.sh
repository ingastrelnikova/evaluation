#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
DB_VM_NAME="db-vm"
METRICS_VM_NAME="metrics-collector-vm"
ZONE="europe-west10-a"
LOCAL_LOG_DIR="./logs"
DB_REMOTE_LOG_FILE="/home/$VM_USER/app/benchmark_reading_metrics/data/write_log.csv"
METRICS_REMOTE_LOG_FILE="/home/$VM_USER/app/benchmark_reading_metrics/data/read_log.csv"
REMOTE_COMPLETION_FILE="/home/$VM_USER/experiment_complete.txt"

# Create the local log directory if it doesn't exist
mkdir -p $LOCAL_LOG_DIR

# Function to check if the experiment is complete
check_experiment_completion() {
    gcloud compute ssh $VM_USER@$DB_VM_NAME --zone=$ZONE -- "test -f $REMOTE_COMPLETION_FILE && echo 'Experiment complete' || echo 'Experiment not complete'"
}

# Function to download log files
download_logs() {
    # Download log file from DB VM
    gcloud compute scp $VM_USER@$DB_VM_NAME:$DB_REMOTE_LOG_FILE $LOCAL_LOG_DIR --zone=$ZONE
    # Download log file from Metrics Collector VM
    gcloud compute scp $VM_USER@$METRICS_VM_NAME:$METRICS_REMOTE_LOG_FILE $LOCAL_LOG_DIR --zone=$ZONE
    echo "Log files downloaded to $LOCAL_LOG_DIR"
}

# Check if the experiment is complete
experiment_status=$(check_experiment_completion)

if [[ $experiment_status == *"Experiment complete"* ]]; then
    download_logs
else
    echo "Experiment not complete yet. Please wait and try again."
fi
