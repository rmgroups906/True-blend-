#!/bin/bash

# AI Analyzer Server Deployment Script
# Server IP: 157.173.218.232

echo "🚀 Starting AI Analyzer deployment..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required software
echo "⚙️ Installing Java 17, Maven, MySQL, Nginx..."
sudo apt install openjdk-17-jdk maven mysql-server nginx certbot python3-certbot-nginx git ufw -y

# Configure firewall
echo "🔒 Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw allow 8080
sudo ufw --force enable

# Verify Java installation
echo "☕ Verifying Java installation..."
java -version

# Configure MySQL
echo "🗄️ Configuring MySQL database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ai_analyzer;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'aiuser'@'localhost' IDENTIFIED BY 'SecureAI2024!';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ai_analyzer.* TO 'aiuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /home/$(whoami)/ai_analyzer
cd /home/$(whoami)/ai_analyzer

echo "✅ Server environment setup complete!"
echo "Next: Upload your application files and run deploy-app.sh"
