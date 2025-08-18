# PowerShell script to upload files to server
# Run this from your local Windows machine

$SERVER_IP = "157.173.218.232"
$USERNAME = "root"  # Change this to your actual username
$LOCAL_PATH = "C:\Users\thevi\OneDrive\Documents\prj-true\True_blend-main\ai_analyzer"
$REMOTE_PATH = "/home/$USERNAME/ai_analyzer"

Write-Host "🚀 Uploading AI Analyzer to server..." -ForegroundColor Green

# Upload application files
Write-Host "📤 Uploading application files..." -ForegroundColor Yellow
scp -r "$LOCAL_PATH" "${USERNAME}@${SERVER_IP}:${REMOTE_PATH}"

# Upload deployment scripts
Write-Host "📤 Uploading deployment scripts..." -ForegroundColor Yellow
scp "C:\Users\thevi\OneDrive\Documents\prj-true\True_blend-main\deploy-server.sh" "${USERNAME}@${SERVER_IP}:/home/$USERNAME/"
scp "C:\Users\thevi\OneDrive\Documents\prj-true\True_blend-main\deploy-app.sh" "${USERNAME}@${SERVER_IP}:/home/$USERNAME/"
scp "C:\Users\thevi\OneDrive\Documents\prj-true\True_blend-main\setup-nginx.sh" "${USERNAME}@${SERVER_IP}:/home/$USERNAME/"
scp "C:\Users\thevi\OneDrive\Documents\prj-true\True_blend-main\deploy-ai-model.sh" "${USERNAME}@${SERVER_IP}:/home/$USERNAME/"

# Upload Python AI model
Write-Host "📤 Uploading Python AI model..." -ForegroundColor Yellow
scp -r "C:\Users\thevi\OneDrive\Documents\prj-true\True_blend-main\ai_model_python" "${USERNAME}@${SERVER_IP}:/home/$USERNAME/"

Write-Host "✅ Upload complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. SSH to server: ssh $USERNAME@$SERVER_IP"
Write-Host "2. Make scripts executable: chmod +x *.sh"
Write-Host "3. Run: ./deploy-server.sh"
Write-Host "4. Run: ./deploy-app.sh"
Write-Host "5. Run: ./setup-nginx.sh"
