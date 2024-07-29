#!/bin/bash

# Define variables
GITHUB_REPO_DIR="/home/ingastrelnikova28/app/benchmark_anonymization/AnonymizationService"

# Ensure Docker Compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

DB_HOST=$(gcloud compute instances describe anon-db --zone=europe-west10-a --format='get(networkInterfaces[0].networkIP)')

export DB_HOST

# Set environment variables for the database
export SPRING_DATASOURCE_URL=jdbc:postgresql://$(gcloud compute instances describe anon-db --zone=europe-west10-a --format='get(networkInterfaces[0].networkIP)'):5432/research
export SPRING_DATASOURCE_USERNAME=test
export SPRING_DATASOURCE_PASSWORD=test

# Navigate to the GitHub repo directory
cd $GITHUB_REPO_DIR

# Pull Docker images and start services with Docker Compose
sudo docker-compose pull
sudo docker-compose up -d

sleep 3600

echo "Anonymization service setup and execution completed."
