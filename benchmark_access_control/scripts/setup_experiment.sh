#!/bin/bash

USER="ingastrelnikova28"

# Define variables
GITHUB_REPO_DIR="/home/$USER/app/benchmark_access_control"

# Ensure Docker Compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Navigate to the GitHub repo
cd $GITHUB_REPO_DIR

# Pull Docker images and start services with Docker Compose
sudo docker-compose pull
sudo docker-compose up --build


