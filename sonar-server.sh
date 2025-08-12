#!/bin/bash
set -e

echo "=============================="
echo "🚀 Starting SonarQube Server Setup"
echo "=============================="

# Update system packages
echo "📦 Updating packages..."
sudo apt-get update -y

# Install prerequisites
echo "📦 Installing required packages..."
sudo apt-get install -y ca-certificates curl

# Add Docker GPG key
echo "🔑 Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "📦 Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "🐳 Installing Docker..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
echo "👤 Adding user 'ubuntu' to docker group..."
sudo usermod -aG docker ubuntu && newgrp docker
newgrp docker
echo "✅ Docker group updated for 'ubuntu'."
sleep 5


# Run SonarQube container
echo "🚀 Running SonarQube container..."
docker run -d -p 9000:9000 --name sonarqube sonarqube:lts-community

echo "=============================="
echo "✅ SonarQube Setup Completed!"
echo "=============================="
echo "🌐 Access SonarQube at: http://<your-server-ip>:9000"
