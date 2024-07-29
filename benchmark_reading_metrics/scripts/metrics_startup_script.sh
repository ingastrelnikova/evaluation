#!/bin/bash

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

# Add Docker's official GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone the repository
git clone https://github.com/ingastrelnikova/evaluation.git /home/ingastrelnikova28/app

# Wait for DB/Load Generator VM to be ready and get its IP
sleep 60
DB_LOADGEN_VM_IP=$(gcloud compute instances describe db-load-vm --zone=europe-west10-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Update the docker-compose.yml file with the DB IP
sed -i.bak "s/DB_HOST:.*/DB_HOST: $DB_LOADGEN_VM_IP/" /home/ingastrelnikova28/app/benchmark_reading_metrics/metrics/docker-compose.yml

## Run Docker Compose
#cd /home/ingastrelnikova28/app/benchmark_reading_metrics/metrics
#sudo docker-compose up -d
