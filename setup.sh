#!/bin/bash    # this file contains all the configuration need to be done to run the jenkins file
set -e

echo "🔧 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "☕ Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java -version

echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

echo "🔓 Granting root permission to Docker..."
sudo usermod -aG docker $USER
newgrp docker

echo "📦 Installing Maven and Node.js..."
sudo apt install -y maven
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

echo "🧰 Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

echo "☸️ Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

echo "🚀 Installing Jenkins..."
sudo apt install -y gnupg2
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "🔐 Adding Jenkins to Docker group..."
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "✅ Setup complete. Reboot recommended to apply all group changes."
