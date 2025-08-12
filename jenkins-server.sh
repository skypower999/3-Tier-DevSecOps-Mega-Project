#!/bin/bash
set -e

echo "=============================="
echo "🚀 Starting Jenkins CI/CD Setup"
echo "=============================="

# Update system
echo "📦 Updating system packages..."
sudo apt update -y

# Install Java for Jenkins
echo "☕ Installing OpenJDK 21..."
sudo apt install -y openjdk-21-jre-headless

# Install Jenkins
echo "🔧 Adding Jenkins repository and key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
echo "📦 Installing Jenkins..."
sudo apt-get install -y jenkins

# Install Gitleaks
echo "🕵️ Installing Gitleaks..."
sudo apt install -y gitleaks

# Install Trivy
echo "🔍 Installing Trivy..."
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy

# ----------------------------------------
# Install kubectl
# ----------------------------------------
if ! command -v kubectl >/dev/null 2>&1; then
  echo "🛠️  Installing kubectl..."
  KUBECTL_VER="$(curl -sL https://dl.k8s.io/release/stable.txt)"
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl.sha256"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check - >/dev/null
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl kubectl.sha256
else
  echo "✅ kubectl already installed: $(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')"
fi

# Install Docker
echo "🐳 Installing Docker..."
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker jenkins

# Enable and start Jenkins & Docker services
echo "🚀 Starting Jenkins and Docker..."
sudo systemctl restart jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl enable docker
sudo systemctl start docker

echo "=============================="
echo "✅ Jenkins CI/CD Setup Completed!"
echo "=============================="
echo "🔑 Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword