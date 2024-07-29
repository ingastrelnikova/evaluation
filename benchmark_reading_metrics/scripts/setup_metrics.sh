#!/bin/bash

# Define variables
GITHUB_REPO_DIR="/home/ingastrelnikova28/app/benchmark_reading_metrics/metrics"
LOG_FILE_PATH="$GITHUB_REPO_DIR/read_log.csv"
COMPLETION_FILE="/home/ingastrelnikova28/metrics_complete.txt"

DB_HOST=$(gcloud compute instances describe db-load-vm --zone=europe-west10-a --format='get(networkInterfaces[0].networkIP)')

export DB_HOST

# Ensure Docker Compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Navigate to the GitHub repo directory
cd $GITHUB_REPO_DIR

# Pull Docker images and start services with Docker Compose
sudo docker-compose pull
sudo docker-compose up -d

# Wait for the metrics collection to finish
sleep 3600  # Adjust based on the expected run time

# Copy the log file from the metrics collector container to the host
METRICS_CONTAINER=$(sudo docker-compose ps -q metrics)
sudo docker cp $METRICS_CONTAINER:/app/read_log.csv $LOG_FILE_PATH

# Stop and remove Docker containers
#sudo docker-compose down

# Create a completion file to indicate the metrics collection has finished
touch $COMPLETION_FILE

echo "Metrics collection completed."
echo "Log file copied to: $LOG_FILE_PATH"
