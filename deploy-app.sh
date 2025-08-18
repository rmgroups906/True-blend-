#!/bin/bash

# AI Analyzer Application Deployment Script
# Run this after deploy-server.sh

echo "🚀 Deploying AI Analyzer application..."

# Navigate to application directory
cd /home/$(whoami)/ai_analyzer

# Create application.properties for production
echo "⚙️ Creating production configuration..."
cat > src/main/resources/application.properties << EOF
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/ai_analyzer
spring.datasource.username=aiuser
spring.datasource.password=SecureAI2024!
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect

# Server Configuration
server.port=8080
server.servlet.context-path=/

# Logging
logging.level.com.example.ai_analyzer=INFO
logging.file.name=logs/ai-analyzer.log

# Security
spring.security.user.name=admin
spring.security.user.password=AdminPass2024!
EOF

# Create logs directory
mkdir -p logs

# Build the application
echo "🔨 Building application..."
mvn clean package -DskipTests

# Stop existing application if running
echo "🛑 Stopping existing application..."
pkill -f "ai_analyzer-0.0.1-SNAPSHOT.jar" || true

# Start the application
echo "▶️ Starting application..."
nohup java -jar target/ai_analyzer-0.0.1-SNAPSHOT.jar > logs/app.log 2>&1 &

# Wait for application to start
echo "⏳ Waiting for application to start..."
sleep 10

# Check if application is running
if pgrep -f "ai_analyzer-0.0.1-SNAPSHOT.jar" > /dev/null; then
    echo "✅ Application started successfully!"
    echo "🌐 Application running on: http://localhost:8080"
else
    echo "❌ Application failed to start. Check logs/app.log"
    exit 1
fi

echo "📋 Application Status:"
echo "- PID: $(pgrep -f ai_analyzer-0.0.1-SNAPSHOT.jar)"
echo "- Logs: tail -f logs/app.log"
echo "- Test: curl http://localhost:8080/actuator/health"
