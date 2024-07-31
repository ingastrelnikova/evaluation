#!/bin/bash

# Update the package list
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker APT repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package list again
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce

# Add user to the docker group
sudo usermod -aG docker ingastrelnikova28

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone GitHub repository
git clone https://github.com/ingastrelnikova/evaluation.git /home/ingastrelnikova28/app

# Change to the app directory
cd /home/ingastrelnikova28/app

## Run Docker Compose
#sudo docker-compose up -d
