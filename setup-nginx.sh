#!/bin/bash

# Nginx Configuration Script for AI Analyzer
# Server IP: 157.173.218.232

echo "🌐 Configuring Nginx reverse proxy..."

# Create Nginx configuration
sudo tee /etc/nginx/sites-available/ai-analyzer << EOF
server {
    listen 80;
    server_name 157.173.218.232;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # Proxy to Spring Boot application
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Proxy to AI Model Python service
    location /ai/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoints
    location /health {
        proxy_pass http://localhost:8080/actuator/health;
        proxy_set_header Host \$host;
        access_log off;
    }
    
    location /ai/health {
        proxy_pass http://localhost:5000/health;
        proxy_set_header Host \$host;
        access_log off;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/ai-analyzer /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "🔍 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
    
    # Reload Nginx
    sudo systemctl reload nginx
    sudo systemctl enable nginx
    
    echo "🌐 Nginx configured successfully!"
    echo "🔗 Your API is now accessible at: http://157.173.218.232/"
    
    # Test the setup
    echo "🧪 Testing deployment..."
    sleep 3
    curl -I http://localhost/ || echo "⚠️ Local test failed - check application status"
    
else
    echo "❌ Nginx configuration failed"
    exit 1
fi

echo ""
echo "📋 Deployment Summary:"
echo "- API Base URL: http://157.173.218.232/"
echo "- Health Check: http://157.173.218.232/health"
echo "- Server Status: systemctl status nginx"
echo "- Application Logs: tail -f /home/$(whoami)/ai_analyzer/logs/app.log"
echo "- Nginx Logs: sudo tail -f /var/log/nginx/access.log"
