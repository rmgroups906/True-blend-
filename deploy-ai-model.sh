#!/bin/bash

# AI Model Python Service Deployment Script
# Run this after deploy-app.sh

echo "🤖 Deploying AI Model Python service..."

# Navigate to AI model directory
cd /home/$(whoami)/ai_model_python

# Install Python dependencies
echo "📦 Installing Python dependencies..."
sudo apt install python3-pip python3-venv -y

# Create virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv ai_env
source ai_env/bin/activate

# Install requirements
echo "📋 Installing Python packages..."
pip install -r requirements.txt

# Create environment file template
echo "⚙️ Creating environment configuration..."
cat > .env << EOF
# Add your Gemini API key here
GEMINI_API_KEY=your_gemini_api_key_here
EOF

echo "⚠️  IMPORTANT: Please add your Gemini API key to .env file"
echo "   Edit: nano .env"

# Create systemd service for AI model
echo "🔧 Creating systemd service..."
sudo tee /etc/systemd/system/ai-model.service << EOF
[Unit]
Description=AI Health Analyzer Python Service
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=/home/$(whoami)/ai_model_python
Environment=PATH=/home/$(whoami)/ai_model_python/ai_env/bin
ExecStart=/home/$(whoami)/ai_model_python/ai_env/bin/python analyze.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "▶️ Starting AI model service..."
sudo systemctl daemon-reload
sudo systemctl enable ai-model.service
sudo systemctl start ai-model.service

# Check service status
echo "📊 Checking service status..."
sudo systemctl status ai-model.service --no-pager

echo "✅ AI Model service deployment complete!"
echo "🔗 AI Model running on: http://localhost:5000"
echo "📋 Service commands:"
echo "- Status: sudo systemctl status ai-model"
echo "- Logs: sudo journalctl -u ai-model -f"
echo "- Restart: sudo systemctl restart ai-model"
