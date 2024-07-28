#!/bin/bash

# Define variables
GITHUB_REPO_DIR="/home/ingastrelnikova28/app/benchmark/data"
LOG_FILE_PATH="$GITHUB_REPO_DIR/write_log.csv"
COMPLETION_FILE="/home/ingastrelnikova28/experiment_complete.txt"

# Ensure Docker Compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Navigate to the GitHub repo directory
cd $GITHUB_REPO_DIR

# Pull Docker images and start services with Docker Compose
sudo docker-compose pull
sudo docker-compose up

# Wait for the load generator to finish
sleep 3600  # Adjust based on the expected run time

# Copy the log file from the load generator container to the host
LOADGEN_CONTAINER=$(sudo docker-compose ps -q loadgen)
sudo docker cp $LOADGEN_CONTAINER:/app/write_log.csv $LOG_FILE_PATH

# Stop and remove Docker containers
sudo docker-compose down

# Create a completion file to indicate the experiment has finished
touch $COMPLETION_FILE

echo "Experiment setup and execution completed."
echo "Log file copied to: $LOG_FILE_PATH"
