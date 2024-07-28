#!/bin/bash

# Pull the Docker images
docker pull postgres:13
docker pull your-dockerhub-username/loadgen:latest

# Create a network for the containers
docker network create loadgen-network

# Run PostgreSQL container
docker run -d --name postgres-db --network loadgen-network \
  -e POSTGRES_DB=research \
  -e POSTGRES_USER=test \
  -e POSTGRES_PASSWORD=test \
  -v pgdata:/var/lib/postgresql/data \
  postgres:13

# Wait for PostgreSQL to initialize
sleep 10

# Run Load Generator container
docker run -d --name loadgen --network loadgen-network \
  -e DB_HOST=postgres-db \
  -e DB_PORT=5432 \
  -e DB_NAME=research \
  -e DB_USER=test \
  -e DB_PASSWORD=test \
  -e CSV_DIR_PATH=/app/anonymized_patients/10000 \
  -e LOG_CSV_PATH=/app/write_log.csv \
  -v /path/to/your/local/csv/files:/app/anonymized_patients \
  your-dockerhub-username/loadgen:latest

# Wait for the load generator to finish
sleep 3600  # Adjust based on the expected run time

# Copy the log file from the load generator container to the host
docker cp loadgen:/app/write_log.csv /home/$USER/write_log.csv

# Stop and remove the containers
docker stop loadgen postgres-db
docker rm loadgen postgres-db

# Remove the Docker network
docker network rm loadgen-network

# Upload the log file to Google Cloud Storage
sudo gsutil cp /home/$USER/write_log.csv gs://your-bucket-name/write_log.csv
