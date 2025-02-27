#!/bin/bash

# Define variables
GITHUB_REPO_DIR="/home/ingastrelnikova28/app/benchmark_anonymization/AnonymizationService"

# Ensure Docker Compose is installed
if ! [ -x "$(command -v docker-compose)" ]; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Navigate to the GitHub repo directory
cd $GITHUB_REPO_DIR

DB_HOST=$(gcloud compute instances describe anon-db --zone=europe-west10-a --format='get(networkInterfaces[0].networkIP)')

# Set environment variables for the database
export SPRING_DATASOURCE_URL="jdbc:postgresql://${DB_HOST}:5432/research"
export SPRING_DATASOURCE_USERNAME="test"
export SPRING_DATASOURCE_PASSWORD="test"

echo "$SPRING_DATASOURCE_URL"

cat <<EOF > .env
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
EOF


# Pull Docker images and start services with Docker Compose
sudo docker-compose pull
sudo docker-compose up -d

