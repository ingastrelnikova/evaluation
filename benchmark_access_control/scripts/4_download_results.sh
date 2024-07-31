#!/bin/bash

# Define variables
VM_USER="ingastrelnikova28"
VM_NAME="access-ctrl"
ZONE="europe-west10-a"

# SSH into the VM and run the setup script
gcloud compute ssh $VM_USER@$VM_NAME --zone=$ZONE --command=""